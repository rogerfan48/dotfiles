// Personal *fallback* ESLint flat config.
//
// Used by Neovim (nvim-lint + eslint_d) ONLY for files that live outside any
// project, i.e. when no local `eslint.config.*` is found walking up from the
// file. Projects with their own config always take precedence.
//
// Kept dependency-free on purpose (no imports / no `@eslint/js` / no `globals`)
// so eslint_d's bundled ESLint can load it from anywhere without a node_modules.
export default [
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
    },
    rules: {
      "no-unused-vars": "warn",
      "no-undef": "off", // runtime (node/browser) is unknown for scratch files
      "no-constant-condition": ["warn", { checkLoops: false }],
      "no-debugger": "warn",
      "no-var": "warn",
      "prefer-const": "warn",
      eqeqeq: ["warn", "smart"],
    },
  },
];
