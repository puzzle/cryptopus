import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | footer", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders", async function (assert) {
    // Set any properties with this.set('myProperty', 'value');
    // Handle any actions with this.set('myAction', function(val) { ... });

    await render(hbs`<Footer />`);

    let footerText = this.element.textContent.trim();
    assert.equal(footerText.includes("Automatic sign out"), true);
    assert.equal(footerText.includes("GitHub"), true);
    assert.equal(footerText.includes("Version"), true);
  });
});
