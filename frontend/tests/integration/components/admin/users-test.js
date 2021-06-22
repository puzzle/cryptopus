import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | admin/users", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders", async function (assert) {
    await render(hbs`
      <Admin::Users>
      </Admin::Users>
    `);

    const text = this.element.textContent.trim();
    assert.ok(text.includes("Users"));
  });
});
