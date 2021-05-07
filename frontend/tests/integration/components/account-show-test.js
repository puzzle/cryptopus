import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";
import { isPresent } from "@ember/utils";

const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return [];
    }
  }
});

module("Integration | Component | account-show", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it renders with data and shows edit buttons for regular account", async function (assert) {
    this.set("account", {
      id: 1,
      accountname: "Ninjas test account",
      description: "Account for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      fileEntries: [
        {
          filename: "file1",
          description: "description for file1",
          account: {
            get() {
              return 1;
            },
            id: 1
          }
        },
        {
          filename: "file2",
          description: "description for file2",
          account: {
            get() {
              return 1;
            },
            id: 1
          }
        }
      ]
    });
    await render(hbs`<AccountShow @account={{this.account}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test account"));
    assert.ok(text.includes("Account for the ninjas"));
    assert.ok(text.includes("file1"));
    assert.ok(text.includes("description for file1"));
    assert.ok(text.includes("file2"));
    assert.ok(text.includes("description for file2"));

    let deleteButton = this.element.querySelector('.icon-button[alt="delete"]');
    let editButton = this.element.querySelector('.icon-button[alt="edit"]');
    assert.ok(isPresent(deleteButton));
    assert.ok(isPresent(editButton));
  });

  test("it renders with data and hides edit buttons for openshift secret", async function (assert) {
    this.set("account", {
      id: 1,
      accountname: "Ninjas test account",
      description: "Account for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      category: "openshift_secret",
      isOseSecret: true,
      fileEntries: [
        {
          filename: "file1",
          description: "description for file1",
          account: {
            get() {
              return 1;
            },
            id: 1
          }
        },
        {
          filename: "file2",
          description: "description for file2",
          account: {
            get() {
              return 1;
            },
            id: 1
          }
        }
      ]
    });
    await render(hbs`<AccountShow @account={{this.account}}/>`);

    let deleteButton = this.element.querySelector(
      '.align-items-center .icon-button[alt="delete"]'
    );
    let editButton = this.element.querySelector('.icon-button[alt="edit"]');
    assert.ok(!isPresent(deleteButton));
    assert.ok(!isPresent(editButton));
  });
});
