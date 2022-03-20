import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, click } from "@ember/test-helpers";
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

  const users = [
    {
      username: "Bob",
      givenname: "Bobby",
      role: "admin",
      lastLoginAt: "11.03.2022 03:03",
      lastLoginFrom: "111.123.22.2",
      auth: "db",
      providerUid: 2,
      isDeleted: false
    },
    {
      username: "Alice",
      givenname: "Allison",
      role: "user",
      lastLoginAt: "12.03.2022 06:56",
      lastLoginFrom: "111.123.22.1",
      auth: "db",
      providerUid: 1,
      isDeleted: false
    },
    {
      username: "Fred",
      isDeleted: true
    }
  ];

  test("it renders with data", async function (assert) {
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

  test("sorting works", async function (assert) {
    this.set("users", users);

    await render(hbs`<Admin::User::Table @users={{this.users}} />`);
    let text = this.element.textContent.trim();

    assert.ok(text.indexOf("Alice") < text.indexOf("Bob"));

    assert.ok(proveDescOrder("sort-username", "Alice", "Bob", this));

    assert.ok(proveAscOrder("sort-name", "Alice", "Bob", this));
    assert.ok(proveDescOrder("sort-name", "Alice", "Bob", this));

    assert.ok(proveAscOrder("sort-role", "admin", "user", this));
    assert.ok(proveDescOrder("sort-role", "admin", "user", this));

    assert.ok(proveAscOrder("sort-auth", "Alice", "Bob", this));
    assert.ok(proveDescOrder("sort-auth", "Alice", "Bob", this));

    assert.ok(proveAscOrder("sort-login-at", "Alice", "Bob", this));
    assert.ok(proveDescOrder("sort-login-at", "Alice", "Bob", this));

    assert.ok(proveAscOrder("sort-login-from", "Alice", "Bob", this));
    assert.ok(proveDescOrder("sort-login-from", "Alice", "Bob", this));

    async function proveAscOrder(elementId, value1, value2, testObject) {
      await click(`span[id='${elementId}']`);
      text = testObject.element.textContent.trim();
      return text.indexOf(value1) < text.indexOf(value2);
    }

    async function proveDescOrder(elementId, value1, value2, testObject) {
      await click(`span[id='${elementId}']`);
      text = testObject.element.textContent.trim();
      return text.indexOf(value1) > text.indexOf(value2);
    }
  });
});
