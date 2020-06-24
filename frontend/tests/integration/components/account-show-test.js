import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | account-show", function(hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function(assert) {
    this.set("account", { name: "Ninjas test account" });
    await render(hbs`<AccountShow @account={{this.account}}/>`);
    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test account"));
  });
});
