import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | admin/user/form", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders without data", async function (assert) {
    await render(hbs`<Admin::User::Form />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Given name"));
    assert.ok(text.includes("Surname"));
    assert.ok(text.includes("Username"));
    assert.ok(text.includes("Password"));
  });

  test("it renders with data", async function (assert) {
    this.set("user", {
      givenname: "Bob",
      surname: "Muster",
      username: "bob"
    });

    await render(hbs`<Admin::User::Form @user={{this.user}}/>`);
    assert.equal(this.element.querySelector("#surname input").value, "Muster");
    assert.equal(this.element.querySelector("#givenname input").value, "Bob");
    assert.equal(this.element.querySelector("#username input").value, "bob");
  });
});
