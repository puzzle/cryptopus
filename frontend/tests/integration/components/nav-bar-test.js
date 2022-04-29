import { module, test } from "qunit";
import ENV from "../../../config/environment";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | nav-bar", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
    ENV.currentUserGivenname = "Alice";
  });

  hooks.afterEach(function () {
    ENV.currentUserGivenname = null;
  });

  test("it renders", async function (assert) {
    await render(hbs`<NavBar />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Help"));
    assert.ok(text.includes("Alice"));
  });
});
