import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, click } from "@ember/test-helpers";
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
      usedAttrs: {
        username: true,
        password: false,
        pin: false,
        token: false,
        email: false,
        custom_attr: false
      }
    });

    await render(
      hbs `<Encryptable::Row @encryptable={{this.encryptable}}/>`
    );

    await new Promise(r => setTimeout(r, 1));

    assert.equal(
      this.element.querySelector("#encryptable-row-title").innerText,
      "mate"
    );
    assert.equal(
      this.element.querySelector("#username-field").innerText,
      "Show username"
    );
    assert.dom(this.element.querySelector("#password-field")).doesNotExist()
    assert.dom(this.element.querySelector("#pin-field")).doesNotExist()
    assert.dom(this.element.querySelector("#email-field")).doesNotExist()
    assert.dom(this.element.querySelector("#token-field")).doesNotExist()
    assert.dom(this.element.querySelector("#custom-attr-field")).doesNotExist()
  });

  test("it renders with two set attribute", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "mate",
      cleartextUsername: "ok",
      cleartextPassword: "ok2",
      usedAttrs: {
        username: true,
        password: true,
        pin: false,
        token: false,
        email: false,
        custom_attr: false
      }
    });

    await render(
      hbs `<Encryptable::Row @encryptable={{this.encryptable}}/>`
    );

    await new Promise(r => setTimeout(r, 1));

    assert.equal(
      this.element.querySelector("#encryptable-row-title").innerText,
      "mate"
    );
    assert.equal(
      this.element.querySelector("#username-field").innerText,
      "Show username"
    );
    assert.equal(
      this.element.querySelector("#password-field").innerText,
      "Show password"
    );
    assert.dom(this.element.querySelector("#pin-field")).doesNotExist()
    assert.dom(this.element.querySelector("#email-field")).doesNotExist()
    assert.dom(this.element.querySelector("#token-field")).doesNotExist()
    assert.dom(this.element.querySelector("#custom-attr-field")).doesNotExist()
  });

  test("it renders with three or more set attribute", async function (assert) {
    this.set("encryptable", {
      id: 1,
      name: "mate",
      cleartextUsername: "ok",
      cleartextPassword: "ok2",
      cleartextPin: "ok3",
      usedAttrs: {
        username: true,
        password: true,
        pin: true,
        token: false,
        email: false,
        custom_attr: false
      }
    });

    await render(
      hbs `<Encryptable::Row @encryptable={{this.encryptable}}/>`
    );

    await new Promise(r => setTimeout(r, 1));

    assert.equal(
      this.element.querySelector("#encryptable-row-title").innerText,
      "mate"
    );
    assert.dom(this.element.querySelector("#username-field")).doesNotExist()
    assert.dom(this.element.querySelector("#password-field")).doesNotExist()
    assert.dom(this.element.querySelector("#pin-field")).doesNotExist()
    assert.dom(this.element.querySelector("#email-field")).doesNotExist()
    assert.dom(this.element.querySelector("#token-field")).doesNotExist()
    assert.dom(this.element.querySelector("#custom-attr-field")).doesNotExist()
  });
});
