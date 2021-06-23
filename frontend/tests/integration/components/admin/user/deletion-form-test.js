import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | admin/user/deletion-form", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with block", async function (assert) {
    await render(hbs`
      <Admin::User::DeletionForm>
        Delete
      </Admin::User::DeletionForm>
    `);

    assert.equal(this.element.textContent.trim(), "Delete");
  });
});
