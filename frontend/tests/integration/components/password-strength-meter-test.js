import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | password-strength-meter", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders with weak password", async function (assert) {
    this.set("password", "gree");

    await render(hbs`<PasswordStrengthMeter @password={{this.password}}/>`);

    assert.ok(this.element.textContent.trim().includes("Password Strength"));
    assert.ok(this.element.textContent.trim().includes("Weak"));

    assert.equal(
      this.element.querySelector(".progress-bar").getAttribute("class"),
      "progress-bar progress-bar-25"
    );
  });

  test("it renders with fair password", async function (assert) {
    this.set("password", "weweojdf");

    await render(hbs`<PasswordStrengthMeter @password={{this.password}}/>`);

    assert.ok(this.element.textContent.trim().includes("Password Strength"));
    assert.ok(this.element.textContent.trim().includes("Fair"));

    assert.equal(
      this.element.querySelector(".progress-bar").getAttribute("class"),
      "progress-bar progress-bar-50"
    );
  });

  test("it renders with good password", async function (assert) {
    this.set("password", "weweojdfdth");

    await render(hbs`<PasswordStrengthMeter @password={{this.password}}/>`);

    assert.ok(this.element.textContent.trim().includes("Password Strength"));
    assert.ok(this.element.textContent.trim().includes("Good"));

    assert.equal(
      this.element.querySelector(".progress-bar").getAttribute("class"),
      "progress-bar progress-bar-75"
    );
  });

  test("it renders with strong password", async function (assert) {
    this.set("password", "weweojdfdthfew");

    await render(hbs`<PasswordStrengthMeter @password={{this.password}}/>`);

    assert.ok(this.element.textContent.trim().includes("Password Strength"));
    assert.ok(this.element.textContent.trim().includes("Strong"));

    assert.equal(
      this.element.querySelector(".progress-bar").getAttribute("class"),
      "progress-bar progress-bar-100"
    );
  });
  test("it renders with fair password", async function (assert) {
    this.set("password", "");

    await render(hbs`<PasswordStrengthMeter @password={{this.password}}/>`);

    assert.ok(this.element.textContent.trim().includes("Password Strength"));
    assert.ok(this.element.textContent.trim().includes("There is no password defined"));

    assert.equal(
      this.element.querySelector(".progress-bar").getAttribute("class"),
      "progress-bar progress-bar-0"
    );
  });
});
