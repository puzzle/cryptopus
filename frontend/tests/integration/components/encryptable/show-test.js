import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | encryptable/show", function(hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    this.set("encryptable", {
      name: "Foo",
      description: "Bla",
      folder: {
        get() {
          return 1;
        }
      }
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Foo"));
  });
});
