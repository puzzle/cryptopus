import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | accounts-edit-modal", function(hooks) {
  setupRenderingTest(hooks);

  test("it renders", async function(assert) {
    // Set any properties with this.set('myProperty', 'value');
    // Handle any actions with this.set('myAction', function(val) { ... });

    await render(hbs`<AccountsEditModal />`);

    assert.ok(this.element.textContent.trim().includes("Launch demo modal"));
    assert.ok(this.element.textContent.trim().includes("Modal title"));
    assert.ok(this.element.textContent.trim().includes("Name"));
    assert.ok(this.element.textContent.trim().includes("Group"));
  });
});
