import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, waitFor } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";



const storeStub = Service.extend({
  query(modelName, params) {
    return new Promise((resolve, reject) => {
      resolve(
        [
          { name: "Team1", description: "description1", destroyRecord: () => { } },
          { name: "Team2", description: "description2", destroyRecord: () => { } }
        ]
      );
    })
  }
});

module("Integration | Component | admin/user/deletion-form", function (hooks) {
  setupRenderingTest(hooks);


  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");

  });

  test("it renders with block", async function (assert) {
    await render(hbs`
      <Admin::User::DeletionForm>
        Delete
      </Admin::User::DeletionForm>
    `);
    assert.equal(this.element.textContent.trim(), "Delete");
  });

  test("Refreshes teams after delete", async function (assert) {
    this.set("user", {
      id: 12,
      givenname: "Bob",
      surname: "Muster",
      username: "bob"
    });

    await render(hbs`
      <Admin::User::DeletionForm @user={{this.user}}>
        Delete
      </Admin::User::DeletionForm>`);

    this.element.querySelector("span[role='button']").click()

    await waitFor('[data-test-id="delete"]', { timeout: 2000 })


    this.element.querySelectorAll('[data-test-id="delete"]').forEach((e) => e.click());
    await waitFor('[data-test-id="delete-user-text"]', { timeout: 2000 })

    const teamsLeft = this.element.querySelectorAll("[data-test-id='delete']").length
    assert.equal(teamsLeft, 0);
  });
});
