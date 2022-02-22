import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | encryptable/card-show", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    this.set("encryptable", {
      name: "Ninjas encryptable",
      description: "Encryptable for the ninjas"
    });
    await render(
      hbs`<Encryptable::CardShow @encryptable={{this.encryptable}}/>`
    );
    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas encryptable"));
    assert.ok(text.includes("Encryptable for the ninjas"));
  });
});
