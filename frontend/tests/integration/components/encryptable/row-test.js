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

  test("it renders encryptable row for normal encryptable credentials", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      sender_name: null
    });

    await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test encryptable"));
    assert.ok(text.includes("Show username"));
    assert.ok(text.includes("Show password"));

    let deleteButton = this.element.querySelector(
      '.icon-medium-button[alt="delete"]'
    );
    let editButton = this.element.querySelector(
      '.icon-medium-button[alt="edit"]'
    );
    let copyButtons = this.element.querySelectorAll(".copy-btn");
    assert.ok(isPresent(deleteButton));
    assert.ok(isPresent(editButton));
    assert.equal(copyButtons.length, 2);
  });

  test("it renders encryptable row for transferred file", async function (assert) {
    this.set("encryptable", {
      id: 1,
      type: "encryptable_files",
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      sender_name: "Bob Beier (bob)",
      isFile: true
    });

    await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test encryptable"));
    assert.ok(text.includes("Bob Beier (bob) / 14.06.2021 09:23"));

    let deleteButton = this.element.querySelector(
      '.icon-medium-button[alt="delete"]'
    );
    let downloadButton = this.element.querySelector(
      '.icon-medium-button[alt="download file"]'
    );
    let fileIcon = this.element.querySelector(
      '.icon-medium-button[alt="file icon"]'
    );
    let personIcon = this.element.querySelector(
      '.icon-medium-button[alt="person icon"]'
    );
    assert.ok(isPresent(deleteButton));
    assert.ok(isPresent(downloadButton));
    assert.ok(isPresent(fileIcon));
    assert.ok(isPresent(personIcon));
  });

  test("it renders encryptable row for transferred credentials", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "Ninjas encryptable credentials",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      sender_name: "Bob Kuchen (bob)"
    });

    await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas encryptable credentials"));
    assert.ok(text.includes("Bob Kuchen (bob) / 14.06.2021 09:23"));

    let keyIcon = this.element.querySelector(
      '.icon-medium-button[alt="key icon"]'
    );
    let deleteButton = this.element.querySelector(
      '.icon-medium-button[alt="delete"]'
    );
    let personIcon = this.element.querySelector(
      '.icon-medium-button[alt="person icon"]'
    );
    assert.ok(isPresent(keyIcon));
    assert.ok(isPresent(deleteButton));
    assert.ok(isPresent(personIcon));
  });
});
