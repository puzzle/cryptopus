import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | api-user/table", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders without apiUsers", async function (assert) {
<<<<<<< HEAD:frontend/tests/integration/components/api-user/table-test.js
=======
    // Set any properties with this.set('myProperty', 'value');
    // Handle any actions with this.set('myAction', function(val) { ... });

>>>>>>> 3d7e3738... Adjust ember nested component access, refs: #403:frontend/tests/integration/components/api-users-table-test.js
    await render(hbs`<ApiUser::Table />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("New"));
    assert.ok(text.includes("No api users"));
  });
});
