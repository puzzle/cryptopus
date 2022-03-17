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
      isDeleted: false
    },
    {
      username: "Alice",
      givenname: "Allison",
      role: "user",
      isDeleted: false
    },
    {
      username: "Fred",
      givenname: "Alfred",
      role: "conf_admin",
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
    assert.ok(text.indexOf("Fred") == -1);

    await click('span[id="sort-username"]');
    text = this.element.textContent.trim();

    assert.ok(text.indexOf("Alice") > text.indexOf("Bob"));
    assert.ok(text.indexOf("Fred") == -1);

    await click('span[id="sort-name"]');
    text = this.element.textContent.trim();

    assert.ok(text.indexOf("Alice") < text.indexOf("Bob"));
    assert.ok(text.indexOf("Fred") == -1);

    await click('span[id="sort-name"]');
    text = this.element.textContent.trim();

    assert.ok(text.indexOf("Alice") > text.indexOf("Bob"));
    assert.ok(text.indexOf("Fred") == -1);
  });
});
