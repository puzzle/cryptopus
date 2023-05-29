import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, click } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";
import { isPresent } from "@ember/utils";
import EmberObject from "@ember/object";

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
  });

  test("it renders with data and shows edit buttons credentials encryptable entry", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      encryptableFiles: [
        {
          id: 1,
          name: "file1.txt",
          description: "description for file1",
          get() {
            return 1;
          }
        },
        {
          id: 1,
          name: "file2.txt",
          description: "description for file2",
          get() {
            return 1;
          }
        }
      ]
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);

    assert
      .dom(this.element.querySelector("#cleartext_password"))
      .doesNotExist();
    //already exists, because it isnt a hidden field by default
    assert.equal(
      this.element.querySelector("#cleartext_username").value,
      "mail"
    );
    assert.dom(this.element.querySelector("#cleartext_token")).doesNotExist();
    assert.dom(this.element.querySelector("#show-token")).doesNotExist();
    assert.dom(this.element.querySelector("#cleartext_pin")).doesNotExist();
    assert.dom(this.element.querySelector("#show-pin")).doesNotExist();
    assert.dom(this.element.querySelector("#cleartext_email")).doesNotExist();
    assert
      .dom(this.element.querySelector("#cleartext_custom_attr"))
      .doesNotExist();
    assert.dom(this.element.querySelector("#show-custom-attr")).doesNotExist();

    await click("#show-password");

    assert.equal(
      this.element.querySelector("#cleartext_password").value,
      "e2jd2rh4g5io7"
    );
    assert.dom(this.element.querySelector("#show_password")).doesNotExist();

    let deleteButton = this.element.querySelector('.icon-button[alt="delete"]');
    let editButton = this.element.querySelector('.icon-button[alt="edit"]');
    assert.ok(isPresent(deleteButton));
    assert.ok(isPresent(editButton));
  });

  test("it renders with other four attibute types", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: {
        label: "label",
        value: "value"
      },
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879"
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);

    //already exists, because it isnt a hidden field by default
    assert.equal(this.element.querySelector("#cleartext_email").value, "email");
    assert
      .dom(this.element.querySelector("#cleartext_username"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("#cleartext_password"))
      .doesNotExist();
    assert.dom(this.element.querySelector("#show_password")).doesNotExist();
    assert.dom(this.element.querySelector("#cleartext_token")).doesNotExist();
    assert.dom(this.element.querySelector("#cleartext_pin")).doesNotExist();
    assert
      .dom(this.element.querySelector("#cleartext_custom_attr"))
      .doesNotExist();
    assert.equal(
      this.element.querySelector("#encryptable-custom-attr-label").innerHTML,
      "label"
    );
    assert.equal(
      this.element.querySelector("#show-custom-attr").innerHTML,
      "Show custom attribute"
    );

    await click("#show-token");

    assert.equal(this.element.querySelector("#cleartext_token").value, "token");
    assert.dom(this.element.querySelector("#show_token")).doesNotExist();

    await click("#show-pin");

    assert.equal(this.element.querySelector("#cleartext_pin").value, "pin");
    assert.dom(this.element.querySelector("#show_pin")).doesNotExist();

    await click("#show-custom-attr");

    assert.equal(
      this.element.querySelector("#cleartext_custom-attr").value,
      "value"
    );
    assert.dom(this.element.querySelector("#show-custom-attr")).doesNotExist();
  });

  test("should render all english translations and encryptable values", async function (assert) {
    setLocale("en");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: {
        label: "label",
        value: "value"
      },
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879"
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);
    assert.equal(
      this.element.querySelector("#encryptable-title").innerText,
      "Credentials: Ninjas test encryptable"
    );
    assert.equal(
      this.element.querySelector("#encryptable-created-at").innerText,
      "Created at: 14.06.2021 09:23"
    );
    assert.equal(
      this.element.querySelector("#encryptable-updated-at").innerText,
      "Last update at: 22.06.2021 11:33"
    );
    assert.equal(
      this.element.querySelector("#encryptable-username-label").innerText,
      "Username"
    );
    assert.equal(
      this.element.querySelector("#encryptable-email-label").innerText,
      "Email"
    );
    assert.equal(
      this.element.querySelector("#encryptable-password-label").innerText,
      "Password"
    );
    assert.equal(
      this.element.querySelector("#show-password").innerText,
      "Show password"
    );
    assert.equal(
      this.element.querySelector("#encryptable-pin-label").innerText,
      "Pin"
    );
    assert.equal(this.element.querySelector("#show-pin").innerText, "Show pin");
    assert.equal(
      this.element.querySelector("#encryptable-token-label").innerText,
      "Token"
    );
    assert.equal(
      this.element.querySelector("#show-token").innerText,
      "Show token"
    );
    assert.equal(
      this.element.querySelector("#show-custom-attr").innerText,
      "Show custom attribute"
    );
    assert.equal(
      this.element.querySelector("#encryptable-attachments").innerText,
      "Attachments"
    );
    assert.equal(
      this.element.querySelector("#encryptable-add-attachment").innerText,
      "Add attachment"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-label").innerText,
      "File"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-description").innerText,
      "Description"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-actions").innerText,
      "Actions"
    );
  });

  test("should render all german translations and encryptable values", async function (assert) {
    setLocale("de");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: {
        label: "label",
        value: "value"
      },
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879"
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);
    assert.equal(
      this.element.querySelector("#encryptable-title").innerText,
      "Zugangsdaten: Ninjas test encryptable"
    );
    assert.equal(
      this.element.querySelector("#encryptable-created-at").innerText,
      "Erstellt am: 14.06.2021 09:23"
    );
    assert.equal(
      this.element.querySelector("#encryptable-updated-at").innerText,
      "Letzte Änderung am: 22.06.2021 11:33"
    );
    assert.equal(
      this.element.querySelector("#encryptable-username-label").innerText,
      "Benutzername"
    );
    assert.equal(
      this.element.querySelector("#encryptable-email-label").innerText,
      "Email"
    );
    assert.equal(
      this.element.querySelector("#encryptable-password-label").innerText,
      "Passwort"
    );
    assert.equal(
      this.element.querySelector("#show-password").innerText,
      "Passwort anzeigen"
    );
    assert.equal(
      this.element.querySelector("#encryptable-pin-label").innerText,
      "Pin"
    );
    assert.equal(
      this.element.querySelector("#show-pin").innerText,
      "Pin anzeigen"
    );
    assert.equal(
      this.element.querySelector("#encryptable-token-label").innerText,
      "Token"
    );
    assert.equal(
      this.element.querySelector("#show-token").innerText,
      "Token anzeigen"
    );
    assert.equal(
      this.element.querySelector("#show-custom-attr").innerText,
      "Individuelles Attribut anzeigen"
    );
    assert.equal(
      this.element.querySelector("#encryptable-attachments").innerText,
      "Anhänge"
    );
    assert.equal(
      this.element.querySelector("#encryptable-add-attachment").innerText,
      "Anhang hinzufügen"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-label").innerText,
      "Datei"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-description").innerText,
      "Beschreibung"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-actions").innerText,
      "Aktionen"
    );
  });

  test("should render all swiss german translations and encryptable values", async function (assert) {
    setLocale("ch_be");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: {
        label: "label",
        value: "value"
      },
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879"
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);
    assert.equal(
      this.element.querySelector("#encryptable-title").innerText,
      "Zuägangsdate: Ninjas test encryptable"
    );
    assert.equal(
      this.element.querySelector("#encryptable-created-at").innerText,
      "Ersteut am: 14.06.2021 09:23"
    );
    assert.equal(
      this.element.querySelector("#encryptable-updated-at").innerText,
      "Letschti Änderig am: 22.06.2021 11:33"
    );
    assert.equal(
      this.element.querySelector("#encryptable-username-label").innerText,
      "Benutzername"
    );
    assert.equal(
      this.element.querySelector("#encryptable-email-label").innerText,
      "Email"
    );
    assert.equal(
      this.element.querySelector("#encryptable-password-label").innerText,
      "Passwort"
    );
    assert.equal(
      this.element.querySelector("#show-password").innerText,
      "Passwort ahzeigä"
    );
    assert.equal(
      this.element.querySelector("#encryptable-pin-label").innerText,
      "Pin"
    );
    assert.equal(
      this.element.querySelector("#show-pin").innerText,
      "Pin ahzeigä"
    );
    assert.equal(
      this.element.querySelector("#encryptable-token-label").innerText,
      "Token"
    );
    assert.equal(
      this.element.querySelector("#show-token").innerText,
      "Token ahzeigä"
    );
    assert.equal(
      this.element.querySelector("#show-custom-attr").innerText,
      "Individuells Attribut ahzeigä"
    );
    assert.equal(
      this.element.querySelector("#encryptable-attachments").innerText,
      "Ahäng"
    );
    assert.equal(
      this.element.querySelector("#encryptable-add-attachment").innerText,
      "Anhang hinzufüegä"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-label").innerText,
      "Datei"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-description").innerText,
      "Beschribig"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-actions").innerText,
      "Aktionä"
    );
  });

  test("should render all french translations and encryptable values", async function (assert) {
    setLocale("fr");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      cleartextToken: "token",
      cleartextPin: "pin",
      cleartextEmail: "email",
      cleartextCustomAttr: {
        label: "label",
        value: "value"
      },
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879"
    });

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);
    assert.equal(
      this.element.querySelector("#encryptable-title").innerText,
      "Compte: Ninjas test encryptable"
    );
    assert.equal(
      this.element.querySelector("#encryptable-created-at").innerText,
      "Créé à: 14.06.2021 09:23"
    );
    assert.equal(
      this.element.querySelector("#encryptable-updated-at").innerText,
      "Dernie changement à: 22.06.2021 11:33"
    );
    assert.equal(
      this.element.querySelector("#encryptable-username-label").innerText,
      "Nom d'utilisateur"
    );
    assert.equal(
      this.element.querySelector("#encryptable-email-label").innerText,
      "E-mail"
    );
    assert.equal(
      this.element.querySelector("#encryptable-password-label").innerText,
      "Mot de passe"
    );
    assert.equal(
      this.element.querySelector("#show-password").innerText,
      "Afficher le mot de passe"
    );
    assert.equal(
      this.element.querySelector("#encryptable-pin-label").innerText,
      "Pin"
    );
    assert.equal(
      this.element.querySelector("#show-pin").innerText,
      "Afficher Pin"
    );
    assert.equal(
      this.element.querySelector("#encryptable-token-label").innerText,
      "Jeton"
    );
    assert.equal(
      this.element.querySelector("#show-token").innerText,
      "Afficher le jeton"
    );
    assert.equal(
      this.element.querySelector("#show-custom-attr").innerText,
      "Afficher l'attribut personnalisé"
    );
    assert.equal(
      this.element.querySelector("#encryptable-attachments").innerText,
      "Attachements"
    );
    assert.equal(
      this.element.querySelector("#encryptable-add-attachment").innerText,
      "Ajouter un attachement"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-label").innerText,
      "Fichier"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-description").innerText,
      "Description"
    );
    assert.equal(
      this.element.querySelector("#encryptable-file-actions").innerText,
      "Actions"
    );
  });

  test("it renders a transferred encryptable file", async function (assert) {
    setLocale("en");
    this.set(
      "encryptable",
      EmberObject.create({
        id: 1,
        type: "encryptable_files",
        name: "Ninjas test encryptable",
        description: "Encryptable for the ninjas",
        sender_name: "Bob Beier",
        isFile: true
      })
    );

    await render(hbs`<Encryptable::Show @encryptable={{this.encryptable}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("File: Ninjas test encryptable"));
    assert.ok(text.includes("Transferred at"));
    assert.ok(text.includes("Encryptable for the ninjas"));
    assert.ok(text.includes("Download file"));
    assert.ok(text.includes("Sender name: Bob Beier"));

    let deleteButton = this.element.querySelector('.icon-button[alt="delete"]');
    assert.ok(isPresent(deleteButton));
  });
});
