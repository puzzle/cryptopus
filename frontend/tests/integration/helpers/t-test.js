import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import hbs from "htmlbars-inline-precompile";
import { setLocale } from "ember-intl/test-support";

module("Integration | Helper | t", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders create in correct locale", async function (assert) {
    this.set("inputValue", "create");

    let intl = this.owner.lookup("service:intl");

    await render(hbs`{{t inputValue}}`);
    assert.equal(this.element.textContent.trim(), "Create");

    intl.setLocale("de");
    await render(hbs`{{t inputValue}}`);
    assert.equal(this.element.textContent.trim(), "Erstellen");
  });
});
