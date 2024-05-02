import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, pauseTest } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";


const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return Promise.all([
        { name: "Team1", description: "description1" },
        { name: "Team2", description: "description2" },
      ]);
    }
  }
});

module("Integration | Component | admin/user/deletion-form", function (hooks) {
  setupRenderingTest(hooks);


  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
  });

  test("it renders with block", async function (assert) {
    await render(hbs`
      <Admin::User::DeletionForm>
        Delete
      </Admin::User::DeletionForm>
    `);

    assert.equal(this.element.textContent.trim(), "Delete");
  });

  test("it renders with block", async function (assert) {
    this.set("user", {
      id: 12,
      givenname: "Bob",
      surname: "Muster",
      username: "bob"
    });

    await render(hbs `<Admin::User::DeletionForm @user={{this.user}}/>`);
    await pauseTest();

    assert.equal(this.element.textContent.trim(), "Delete");
  });
});
