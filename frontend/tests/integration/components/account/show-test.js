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

module("Integration | Component | encryptable/show", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it renders with data and shows edit buttons for regular encryptable", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      fileEntries: [
        {
          filename: "file1",
          description: "description for file1",
          encryptable: {
            get() {
              return 1;
            },
            id: 1
          }
        },
        {
          filename: "file2",
          description: "description for file2",
          encryptable: {
            get() {
              return 1;
            },
            id: 1
          }
        }
      ]
    });
    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test encryptable"));
    assert.ok(text.includes("Encryptable for the ninjas"));
    assert.ok(text.includes("14.06.2021 09:23"));
    assert.ok(text.includes("22.06.2021 11:33"));
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
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      category: "openshift_secret",
      isOseSecret: true,
      fileEntries: [
        {
          filename: "file1",
          description: "description for file1",
          encryptable: {
            get() {
              return 1;
            },
            id: 1
          }
        },
        {
          filename: "file2",
          description: "description for file2",
          encryptable: {
            get() {
              return 1;
            },
            id: 1
          }
        }
      ]
    });
    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test encryptable"));
    assert.ok(text.includes("Encryptable for the ninjas"));
    assert.ok(text.includes("14.06.2021 09:23"));
    assert.ok(text.includes("22.06.2021 11:33"));
    assert.ok(text.includes("file1"));
    assert.ok(text.includes("description for file1"));
    assert.ok(text.includes("file2"));
    assert.ok(text.includes("description for file2"));

    let deleteButton = this.element.querySelector(
      '.align-items-center .icon-button[alt="delete"]'
    );
    let editButton = this.element.querySelector('.icon-button[alt="edit"]');
    assert.ok(!isPresent(deleteButton));
    assert.ok(!isPresent(editButton));
  });
});
