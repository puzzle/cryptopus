import { module } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | encryptable/row", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  // test("it renders encryptable file row", async function (assert) {
  //   this.set("encryptable", {
  //     id: 1,
  //     name: "Twitter account secret.txt",
  //     isFile: true
  //   });
  //
  //   await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);
  //
  //   let text = this.element.textContent.trim();
  //   assert.ok(text.includes("Twitter account secret.txt"));
  // });
});
