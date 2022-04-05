module.exports = {
  root: true,
  parser: "babel-eslint",
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: "module",
    ecmaFeatures: {
      legacyDecorators: true
    }
  },
  plugins: ["ember"],
  extends: [
    "eslint:recommended",
    "plugin:ember/recommended",
    "plugin:prettier/recommended"
  ],
  env: {
    browser: true,
    jquery: true
  },
  rules: {
    "ember/no-global-jquery": "off",
    "ember/no-classic-classes": "off",
    "ember/require-tagless-components": "off",
    "ember/no-classic-components": "off",
    "ember/no-component-lifecycle-hooks": "off",
    "ember/no-empty-glimmer-component-classes": "off",
    "space-before-function-paren": ["off", "always"],
    "ember/no-jquery": "off"
  },
  overrides: [
    // node files
    {
      files: [
        ".eslintrc.js",
        ".prettierrc.js",
        ".template-lintrc.js",
        "ember-cli-build.js",
        "testem.js",
        "blueprints/*/index.js",
        "config/**/*.js",
        "lib/*/index.js",
        "server/**/*.js"
      ],
      parserOptions: {
        sourceType: "script"
      },
      env: {
        browser: false,
        node: true
      },
      plugins: ["node"],
      rules: Object.assign(
        {},
        require("eslint-plugin-node").configs.recommended.rules,
        {
          // add your custom rules and overrides for node files here

          // this can be removed once the following is fixed
          // https://github.com/mysticatea/eslint-plugin-node/issues/77
          "node/no-unpublished-require": "off"
        }
      )
    }
  ]
};
