import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | password-strength-meter", function(hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function() {
    setLocale("en");
  });

  test("it renders", async function(assert) {
    this.set("password", "red");

    await render(hbs`<PasswordStrengthMeter @password=this.password/>`);

    assert.equal(this.element.textContent.trim(), "Password Strength");

    assert.equal(
      this.element.querySelector(".progress-bar").getAttribute("class"),
      "progress-bar progress-bar-50"
    );
  });
});
