const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

// Helper function to get the FCM token of a user (customer or owner)
const getFCMToken = async (userId, isOwner = false) => {
    const collection = isOwner ? "owners" : "users";
    const userRef = admin.firestore().collection(collection).doc(userId);
    const userDoc = await userRef.get();
    return userDoc.exists ? userDoc.data().fcmToken : null;
};

// Function to send notifications
const sendNotification = async (fcmToken, title, body, imageUrl = null) => {
    if (!fcmToken) return;

    const message = {
        notification: { title, body, imageUrl },
        token: fcmToken,
    };

    try {
        await admin.messaging().send(message);
        console.log(`Notification sent successfully to token: ${fcmToken}`);
    } catch (error) {
        console.error("Error sending notification:", error);
    }
};

// Firestore trigger for new bookings
exports.onNewBooking = onDocumentCreated("bookings/{bookingId}", async (event) => {
    const bookingData = event.data.data();
    if (!bookingData) return;

    const userId = bookingData.userId;
    const ownerId = bookingData.ownerId;

    // Fetch FCM tokens dynamically
    const [userFcmToken, ownerFcmToken] = await Promise.all([
        getFCMToken(userId),
        getFCMToken(ownerId, true),
    ]);

    // Send notification to user
    await sendNotification(userFcmToken, "Booking Confirmed", "Your booking has been confirmed.");

    // Send notification to owner
    await sendNotification(ownerFcmToken, "New Booking Alert", "A new booking has been made.");
});

// Firestore trigger for new product bookings
exports.onNewProductBooking = onDocumentCreated("productbookings/{productBookingId}", async (event) => {
    const productBookingData = event.data.data();
    if (!productBookingData) return;

    const userId = productBookingData.userId;
    const ownerId = productBookingData.ownerId;

    // Fetch FCM tokens dynamically
    const [userFcmToken, ownerFcmToken] = await Promise.all([
        getFCMToken(userId),
        getFCMToken(ownerId, true),
    ]);

    // Send notification to user
    await sendNotification(userFcmToken, "Product Booking Confirmed", "Your product booking has been confirmed.");

    // Send notification to owner
    await sendNotification(ownerFcmToken, "New Product Booking Alert", "A new product booking has been made.");
});

// Firestore trigger for new products added by an owner
exports.onNewProductAdded = onDocumentCreated("owners/{ownerId}/products/{productId}", async (event) => {
    const productData = event.data.data();
    if (!productData) return;

    const { name, imageUrl } = productData; // Assuming product document has name & imageUrl

    // Fetch all users' FCM tokens
    const usersSnapshot = await admin.firestore().collection("users").get();
    const userTokens = usersSnapshot.docs
        .map(doc => doc.data().fcmToken)
        .filter(token => token); // Filter out null tokens

    // Send notification to all users
    const notificationPromises = userTokens.map(token => 
        sendNotification(token, "New Product Added!", `Check out our new product: ${name}`, imageUrl)
    );

    await Promise.all(notificationPromises);
});
