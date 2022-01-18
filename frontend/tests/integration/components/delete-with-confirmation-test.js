import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | delete-with-confirmation", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    this.set("record", {
      constructor: {
        modelName: "encryptable"
      }
    });

    await render(hbs`
      <DeleteWithConfirmation @record={{this.record}}>
        Delete button
      </DeleteWithConfirmation>
    `);

    assert.ok(this.element.textContent.trim().includes("Delete button"));
  });
});
