import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { click, render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module(
  "Integration | Component | encryptable/attribute-field",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      setLocale("en");
    });

    test("it renders with hidden data as row field", async function (assert) {
      this.set("encryptable", {
        id: 1,
        cleartextUsername: "mail"
      });

      await render(
        hbs`<Encryptable::AttributeField @encryptable={{this.encryptable}} @row={{true}} @attribute="username" @visibleByDefault={{false}} />`
      );

      assert
        .dom(this.element.querySelector("#encryptable-username-label"))
        .doesNotExist();
      assert
        .dom(this.element.querySelector("#cleartext_username"))
        .doesNotExist();
      assert.equal(
        this.element.querySelector("#show-username").innerText,
        "Show username"
      );

      await click("#show-username");

      assert.dom(this.element.querySelector("#show-username")).doesNotExist();
      assert.equal(
        this.element.querySelector("#cleartext_username").value,
        "mail"
      );
    });

    test("it renders with data as show field", async function (assert) {
      this.set("encryptable", {
        id: 1,
        cleartextPassword: "mail"
      });

      await render(
        hbs`<Encryptable::AttributeField @encryptable={{this.encryptable}} @row={{false}} @attribute="password" @visibleByDefault={{false}} />`
      );

      assert
        .dom(this.element.querySelector("#cleartext_password"))
        .doesNotExist();
      assert.equal(
        this.element.querySelector("#show-password").innerText,
        "Show password"
      );
      assert.equal(
        this.element.querySelector("#encryptable-password-label").innerText,
        "Password"
      );

      await click("#show-password");

      assert.dom(this.element.querySelector("#show-password")).doesNotExist();
      assert.equal(
        this.element.querySelector("#cleartext_password").value,
        "mail"
      );
    });

    test("it renders with visible by default data as show field", async function (assert) {
      this.set("encryptable", {
        id: 1,
        cleartextPassword: "mail"
      });

      await render(
        hbs`<Encryptable::AttributeField @encryptable={{this.encryptable}} @row={{false}} @attribute="password" @visibleByDefault={{true}} />`
      );

      assert.equal(
        this.element.querySelector("#encryptable-password-label").innerText,
        "Password"
      );
      assert.dom(this.element.querySelector("#show-password")).doesNotExist();
      assert.equal(
        this.element.querySelector("#cleartext_password").value,
        "mail"
      );
    });
  }
);
