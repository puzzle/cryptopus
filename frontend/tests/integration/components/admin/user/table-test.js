import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";
import ENV from "../../../../../config/environment";

module("Integration | Component | admin/user/table", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
    ENV.currentUserGivenname = "Alice";
  });

  hooks.afterEach(function () {
    ENV.currentUserGivenname = null;
  });

  test("it renders with data", async function (assert) {
    const users = [
      {
        username: "Bob",
        isDeleted: false
      },
      {
        username: "Alice",
        isDeleted: false
      },
      {
        username: "Fred",
        isDeleted: true
      }
    ];

    this.set("users", users);

    await render(hbs`<Admin::User::Table @users={{this.users}} />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Username"));
    assert.ok(text.includes("Name"));
    assert.ok(text.includes("Last login at"));
    assert.ok(text.includes("Last login from"));
    assert.ok(text.includes("AUTH PROVIDER"));
    assert.ok(text.includes("Role"));
    assert.ok(text.includes("Action"));

    assert.ok(text.includes("Bob"));

    assert.ok(text.includes("Alice"));

    assert.ok(!text.includes("Fred"));
  });
});
