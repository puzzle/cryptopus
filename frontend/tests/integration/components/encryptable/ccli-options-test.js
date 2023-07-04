import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | encryptable/ccli-options", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders without any set attribute", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-label").innerText,
      "Get encryptable with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-input").value,
      "cry encryptable 1"
    );
    assert
      .dom(this.element.querySelector("#encryptable-ccli-username-label"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("#ccli-username-input"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("#encryptable-ccli-password-label"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("#ccli-password-input"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("#encryptable-ccli-pin-label"))
      .doesNotExist();
    assert.dom(this.element.querySelector("#ccli-pin-input")).doesNotExist();
    assert
      .dom(this.element.querySelector("#encryptable-ccli-token-label"))
      .doesNotExist();
    assert.dom(this.element.querySelector("#ccli-token-input")).doesNotExist();
    assert
      .dom(this.element.querySelector("#encryptable-ccli-email-label"))
      .doesNotExist();
    assert.dom(this.element.querySelector("#ccli-email-input")).doesNotExist();
    assert
      .dom(this.element.querySelector("#encryptable-ccli-custom-attr-label"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("#ccli-custom-attr-input"))
      .doesNotExist();
    assert.equal(
      this.element.querySelector("#encryptable-ccli-yaml-label").innerText,
      "Get encryptable with CCLI as yaml"
    );
    assert.equal(
      this.element.querySelector("#ccli-yaml-input").value,
      "cry encryptable 1 > encryptable.yaml"
    );
  });

  test("it renders with username and password commands", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 9817,
      name: "Ninjas test encryptable",
      cleartextUsername: "yanickegli123",
      cleartextPassword: "findableongithub"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-username-label").innerText,
      "Get username with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-username-input").value,
      "cry encryptable 9817 --username"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-password-label").innerText,
      "Get password with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-password-input").value,
      "cry encryptable 9817 --password"
    );
  });

  test("it renders with pin and email commands", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 6110,
      name: "Ninjas test encryptable",
      cleartextPin: "123456",
      cleartextEmail: "email@email.com"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-email-label").innerText,
      "Get email with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-email-input").value,
      "cry encryptable 6110 --email"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-pin-label").innerText,
      "Get pin with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-pin-input").value,
      "cry encryptable 6110 --pin"
    );
  });

  test("it renders with token and custom attribute commands", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 6110,
      name: "Ninjas test encryptable",
      cleartextToken: "yoanXiTa",
      cleartextCustomAttr: "wow"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-token-label").innerText,
      "Get token with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-token-input").value,
      "cry encryptable 6110 --token"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-custom-attr-label")
        .innerText,
      "Get custom attribute with CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-custom-attr-input").value,
      "cry encryptable 6110 --customAttribute"
    );
  });

  test("should render all english translations with every command", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: "customAttr"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-label").innerText,
      "Get encryptable with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-username-label").innerText,
      "Get username with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-password-label").innerText,
      "Get password with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-email-label").innerText,
      "Get email with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-pin-label").innerText,
      "Get pin with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-token-label").innerText,
      "Get token with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-custom-attr-label")
        .innerText,
      "Get custom attribute with CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-yaml-label").innerText,
      "Get encryptable with CCLI as yaml"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-close-button").innerText,
      "Close"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-help").innerText,
      "You need more information?"
    );
  });

  test("should render all german translations with every command", async function (assert) {
    setLocale("de");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: "customAttr"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-label").innerText,
      "Encryptable anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-username-label").innerText,
      "Benutzername anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-password-label").innerText,
      "Passwort anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-email-label").innerText,
      "Email anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-pin-label").innerText,
      "Pin anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-token-label").innerText,
      "Token anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-custom-attr-label")
        .innerText,
      "Individuelles Attribut anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-yaml-label").innerText,
      "Encryptable als yaml anzeigen mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-close-button").innerText,
      "Schliessen"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-help").innerText,
      "Brauchst du mehr Informationen?"
    );
  });

  test("should render all swiss german translations with every command", async function (assert) {
    setLocale("ch-be");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: "customAttr"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-label").innerText,
      "Encryptable ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-username-label").innerText,
      "Benutzername ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-password-label").innerText,
      "Passwort ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-email-label").innerText,
      "Email ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-pin-label").innerText,
      "Pin ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-token-label").innerText,
      "Token ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-custom-attr-label")
        .innerText,
      "Individuells Attribut ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-yaml-label").innerText,
      "Encryptable als yaml ahzeigä mit CCLI"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-close-button").innerText,
      "Schliessä"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-help").innerText,
      "Bruchsch meh Informationä?"
    );
  });

  test("should render all french translations with every command", async function (assert) {
    setLocale("fr");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: "customAttr"
    });

    await render(
      hbs`<Encryptable::CcliOptions @encryptable={{this.encryptable}}/>`
    );

    assert.equal(
      this.element.querySelector("#encryptable-ccli-label").innerText,
      "Soyez cryptable avec CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-username-label").innerText,
      "Obtenir le nom d'utilisateur avec ccli"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-password-label").innerText,
      "Obtenir un mot de passe avec CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-email-label").innerText,
      "Recevoir des e-mails avec CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-pin-label").innerText,
      "Obtenez l'épingle avec CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-token-label").innerText,
      "Obtenez un jeton avec CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-custom-attr-label")
        .innerText,
      "Obtenir un attribut personnalisé avec CCLI"
    );
    assert.equal(
      this.element.querySelector("#encryptable-ccli-yaml-label").innerText,
      "Devenez cryptable avec CCLI en tant que yaml"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-close-button").innerText,
      "Fermer"
    );
    assert.equal(
      this.element.querySelector("#ccli-options-help").innerText,
      "Avez-vous besoin de plus d'informations?"
    );
  });
});
