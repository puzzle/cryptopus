import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | api-users-table-row", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders with data without lastLogin", async function (assert) {
    let now = new Date();
    this.set("apiUser", {
      username: "bob-a1b2c3",
      description: "CCLI User",
      validUntil: now,
      validFor: 30,
      locked: true
    });

    await render(hbs`<ApiUsersTableRow @apiUser={{this.apiUser}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("bob-a1b2c3"));
    /* eslint-disable no-undef  */
    assert.ok(text.includes(moment(now).format("DD.MM.YYYY hh:mm")));
    /* eslint-enable no-undef  */
  });

  test("it renders with data with lastLoginAt", async function (assert) {
    let now = new Date();
    this.set("apiUser", {
      username: "bob-a1b2c3",
      description: "CCLI User",
      lastLoginAt: now,
      locked: false
    });

    await render(hbs`<ApiUsersTableRow @apiUser={{this.apiUser}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("bob-a1b2c3"));
    assert.ok(text.includes("At:"));
    /* eslint-disable no-undef  */
    assert.ok(text.includes(moment(now).format("DD.MM.YYYY hh:mm")));
    /* eslint-enable no-undef  */
  });

  test("it renders with data with lastLoginFrom", async function (assert) {
    this.set("apiUser", {
      username: "bob-a1b2c3",
      description: "CCLI User",
      lastLoginFrom: "127.0.0.1",
      locked: false
    });

    await render(hbs`<ApiUsersTableRow @apiUser={{this.apiUser}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("bob-a1b2c3"));
    assert.ok(text.includes("From:"));
    assert.ok(text.includes("127.0.0.1"));
  });
});
