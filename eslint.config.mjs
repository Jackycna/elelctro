export default [
  {
    ignores: ["node_modules/", "dist/"],
  },
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "module",
      globals: {
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        process: "readonly",
      },
    },
    rules: {
      "no-unused-vars": "warn",
      "no-undef": "off",
    },
  },
];
