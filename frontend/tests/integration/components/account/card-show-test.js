import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | account/card-show", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    this.set("account", {
      name: "Ninjas account",
      description: "Account for the ninjas"
    });
    await render(hbs`<Account::CardShow @account={{this.account}}/>`);
    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas account"));
    assert.ok(text.includes("Account for the ninjas"));
  });
});
