import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";
import ENV from "../../../../config/environment";

module("Integration | Component | profile/password-update", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders for user with db as auth provider", async function (assert) {
    let tempUserAuth = ENV.currentUserAuth;
    ENV.currentUserAuth = "db";

    await render(hbs`<Profile::PasswordUpdate />`);

    const text = this.element.textContent.trim();
    assert.ok(text.includes("Manage password"));

    ENV.currentUserAuth = tempUserAuth;
  });

  test("it does not render for user with ldap or oidc auth provider", async function (assert) {
    let tempUserAuth = ENV.currentUserAuth;
    ENV.currentUserAuth = "oidc";

    await render(hbs`<Profile::PasswordUpdate />`);

    const text = this.element.textContent.trim();
    assert.notOk(text.includes("Manage password"));

    ENV.currentUserAuth = tempUserAuth;
  });
});
