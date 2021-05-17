import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | admin/user/table", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders without data", async function (assert) {
    await render(hbs`<Admin::User::Table />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Username"));
    assert.ok(text.includes("Name"));
    assert.ok(text.includes("Last login at"));
    assert.ok(text.includes("Last login from"));
    assert.ok(text.includes("PROVIDER UID"));
    assert.ok(text.includes("Role"));
    assert.ok(text.includes("Action"));
  });
});
