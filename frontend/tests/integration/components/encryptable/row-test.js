import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";

const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return [];
    }
  }
});

module("Integration | Component | encryptable/row", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it renders with one set attribute", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "mate",
      cleartextUsername: "ok",
      usedEncryptedDataAttrs: ["username"]
    });

    await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);

    await new Promise((r) => setTimeout(r, 10));

    assert.equal(
      this.element.querySelector("#encryptable-row-title").innerText,
      "mate"
    );
    assert.equal(
      this.element.querySelector("#show-username").innerText,
      "Show username"
    );
    assert.dom(this.element.querySelector("#password-field")).doesNotExist();
    assert.dom(this.element.querySelector("#pin-field")).doesNotExist();
    assert.dom(this.element.querySelector("#email-field")).doesNotExist();
    assert.dom(this.element.querySelector("#token-field")).doesNotExist();
    assert.dom(this.element.querySelector("#custom-attr-field")).doesNotExist();
  });

  test("it renders with two set attribute", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "mate",
      cleartextUsername: "ok",
      cleartextPassword: "ok2",
      usedEncryptedDataAttrs: ["username", "password"]
    });

    await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);

    await new Promise((r) => setTimeout(r, 10));

    assert.equal(
      this.element.querySelector("#encryptable-row-title").innerText,
      "mate"
    );
    assert.equal(
      this.element.querySelector("#show-username").innerText,
      "Show username"
    );
    assert.equal(
      this.element.querySelector("#show-password").innerText,
      "Show password"
    );
    assert.dom(this.element.querySelector("#show-pin")).doesNotExist();
    assert.dom(this.element.querySelector("#show-email")).doesNotExist();
    assert.dom(this.element.querySelector("#show-token")).doesNotExist();
    assert.dom(this.element.querySelector("#show-customAttr")).doesNotExist();
  });

  test("it renders with three or more set attribute", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "mate",
      cleartextUsername: "ok",
      cleartextPassword: "ok2",
      cleartextPin: "ok3",
      usedEncryptedDataAttrs: ["username", "password", "pin"]
    });

    await render(hbs`<Encryptable::Row @encryptable={{this.encryptable}}/>`);

    await new Promise((r) => setTimeout(r, 10));

    assert.equal(
      this.element.querySelector("#encryptable-row-title").innerText,
      "mate"
    );
    assert.dom(this.element.querySelector("#username-field")).doesNotExist();
    assert.dom(this.element.querySelector("#password-field")).doesNotExist();
    assert.dom(this.element.querySelector("#pin-field")).doesNotExist();
    assert.dom(this.element.querySelector("#email-field")).doesNotExist();
    assert.dom(this.element.querySelector("#token-field")).doesNotExist();
    assert.dom(this.element.querySelector("#custom-attr-field")).doesNotExist();
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

    await new Promise((r) => setTimeout(r, 1));

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

    await new Promise((r) => setTimeout(r, 1));

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
