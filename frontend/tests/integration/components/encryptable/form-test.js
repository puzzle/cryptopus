import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, click } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { selectChoose } from "ember-power-select/test-support";
import { setLocale } from "ember-intl/test-support";

const navServiceStub = Service.extend({
  /* eslint-disable ember/avoid-leaking-state-in-ember-objects */
  sortedTeams: [
    {
      id: 1,
      name: "supporting",
      description: "supporting folders",
      folder: [1],
      get() {
        return 1;
      }
    },
    {
      id: 2,
      name: "personal-team",
      type: "Team::Personal",
      folder: [],
      isPersonalTeam: true,
      get() {
        return 2;
      }
    }
  ],
  /* eslint-enable ember/avoid-leaking-state-in-ember-objects */
  selectedFolder: {
    id: 1,
    name: "bbt",
    teamId: 1,
    team: {
      id: 1,
      name: "bbteam",
      get() {
        return 1;
      }
    },
    get(property) {
      if (property === "team") {
        return this.team;
      }
      return this[property];
    }
  }
});

const userServiceStub = Service.extend({
  username: "bob"
});

const storeStub = Service.extend({
  createRecord() {
    return { folder: null, isNew: true, isFullyLoaded: true };
  },
  query(modelName) {
    if (modelName === "folder") {
      return Promise.all([
        {
          id: 1,
          name: "bbt",
          teamId: {
            get() {
              return 1;
            }
          }
        }
      ]);
    }
  },
  peekAll(modelName) {
    if (modelName === "folder") {
      return [
        {
          id: 1,
          name: "bbt",
          team: {
            get() {
              return 1;
            }
          }
        }
      ];
    }
  },
  findAll(modelName) {
    if (modelName === "team")
      return Promise.all([
        {
          id: 1,
          name: "bbteam",
          get() {
            return 1;
          }
        },
        {
          id: 2,
          name: "personal-team",
          type: "Team::Personal",
          isPersonalTeam: true,
          get() {
            return 2;
          }
        }
      ]);
  }
});

module("Integration | Component | encryptable/form", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.unregister("service:navService");
    this.owner.unregister("service:userService");

    this.owner.register("service:store", storeStub);
    this.owner.register("service:navService", navServiceStub);
    this.owner.register("service:userService", userServiceStub);
  });

  test("it renders all english translations without input data", async function (assert) {
    setLocale("en");

    await render(hbs`<Encryptable::Form />`);

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Team bbteam"
    );

    await selectChoose(
      "#team-power-select .ember-power-select-trigger",
      "bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Team bbteam"
    );

    await selectChoose(
      "#folder-power-select .ember-power-select-trigger",
      "bbt"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select")
        .innerText.replace(/\s+/g, " "),
      "Folder bbt ×"
    );

    assert.equal(
      this.element.querySelector("#encryptable-form-accountname").innerText,
      "Accountname"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-description").innerText,
      "Description"
    );
    assert.equal(
      this.element.querySelector("#username-field").innerText,
      "Username"
    );
    assert.equal(
      this.element
        .querySelector("#password-field")
        .innerText.replace(/\s+/g, " "),
      "Password There is no password defined Random password"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-save-button").innerText,
      "Save"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-close-button").innerText,
      "Close"
    );
  });

  test("it renders all german translations without input data", async function (assert) {
    setLocale("de");

    await render(hbs`<Encryptable::Form />`);

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Team bbteam"
    );

    await selectChoose(
      "#team-power-select .ember-power-select-trigger",
      "bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Team bbteam"
    );

    await selectChoose(
      "#folder-power-select .ember-power-select-trigger",
      "bbt"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select")
        .innerText.replace(/\s+/g, " "),
      "Ordner bbt ×"
    );

    assert.equal(
      this.element.querySelector("#encryptable-form-accountname").innerText,
      "Accountname"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-description").innerText,
      "Beschreibung"
    );
    assert.equal(
      this.element.querySelector("#username-field").innerText,
      "Benutzername"
    );
    assert.equal(
      this.element
        .querySelector("#password-field")
        .innerText.replace(/\s+/g, " "),
      "Passwort Es ist kein Passwort gesetzt Zufälliges Passwort"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-save-button").innerText,
      "Speichern"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-close-button").innerText,
      "Schliessen"
    );
  });

  test("it renders all swiss german translations without input data", async function (assert) {
    setLocale("ch_be");

    await render(hbs`<Encryptable::Form />`);

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Team bbteam"
    );

    await selectChoose(
      "#team-power-select .ember-power-select-trigger",
      "bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Team bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select")
        .innerText.replace(/\s+/g, " "),
      "Ordner Wähl ä Ordner us"
    );

    await selectChoose(
      "#folder-power-select .ember-power-select-trigger",
      "bbt"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select")
        .innerText.replace(/\s+/g, " "),
      "Ordner bbt ×"
    );

    assert.equal(
      this.element.querySelector("#encryptable-form-accountname").innerText,
      "Accountname"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-description").innerText,
      "Beschribig"
    );
    assert.equal(
      this.element.querySelector("#username-field").innerText,
      "Benutzername"
    );
    assert.equal(
      this.element
        .querySelector("#password-field")
        .innerText.replace(/\s+/g, " "),
      "Passwort Es isch kes Passwort gsetzt Zuefäuigs Passwort"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-save-button").innerText,
      "Spichere"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-close-button").innerText,
      "Schliessä"
    );
  });

  test("it renders all french translations without input data", async function (assert) {
    setLocale("fr");

    await render(hbs`<Encryptable::Form />`);

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Équipe bbteam"
    );

    await selectChoose(
      "#team-power-select .ember-power-select-trigger",
      "bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#team-power-select")
        .innerText.replace(/\s+/g, " "),
      "Équipe bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select")
        .innerText.replace(/\s+/g, " "),
      "Dossier Choisissez un dossier"
    );

    await selectChoose(
      "#folder-power-select .ember-power-select-trigger",
      "bbt"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select")
        .innerText.replace(/\s+/g, " "),
      "Dossier bbt ×"
    );

    assert.equal(
      this.element.querySelector("#encryptable-form-accountname").innerText,
      "Nom du compte"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-description").innerText,
      "Description"
    );
    assert.equal(
      this.element.querySelector("#username-field").innerText,
      "Nom d'utilisateur"
    );
    assert.equal(
      this.element
        .querySelector("#password-field")
        .innerText.replace(/\s+/g, " "),
      "Mot de passe Il n'a pas un mot de passe Mot de passe aléatoire"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-save-button").innerText,
      "Sauvegarder"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-close-button").innerText,
      "Fermer"
    );
  });

  test("it renders with input data and all attributes", async function (assert) {
    setLocale("en");
    this.set("folder", {
      id: 1,
      name: "bbt",
      get() {
        return {
          name: "supporting",
          get() {
            return 1;
          }
        };
      }
    });
    this.set("encryptable", {
      id: 1,
      name: "My secret Credentials",
      cleartextUsername: "myusernameisboring",
      cleartextPassword: "lol",
      cleartextToken: "loltoken",
      cleartextPin: "thispinisbad",
      cleartextEmail: "mail@ember.com",
      description: "The ember email",
      folder: this.folder,
      isFullyLoaded: true
    });

    await render(hbs`<Encryptable::Form @encryptable={{this.encryptable}}/>`);
    assert.equal(
      this.element.querySelector("textarea").value,
      "The ember email"
    );
    assert.equal(
      this.element.querySelector("#username input").value,
      "myusernameisboring"
    );
    assert.equal(
      this.element.querySelector("#encryptable-form-accountname input").value,
      "My secret Credentials"
    );

    assert.equal(this.element.querySelector("#password input").value, "lol");
    assert.equal(
      this.element.querySelector("#pin-field input").value,
      "thispinisbad"
    );
    assert.equal(this.element.querySelector("#token input").value, "loltoken");
    assert.equal(
      this.element.querySelector("#email input").value,
      "mail@ember.com"
    );
    assert.ok(this.element.textContent.trim().includes("supporting"));
    assert.ok(this.element.textContent.trim().includes("bbt"));
  });

  test("it renders only with set attributes", async function (assert) {
    setLocale("en");
    this.set("folder", {
      id: 1,
      name: "bbt",
      get() {
        return {
          name: "supporting",
          get() {
            return 1;
          }
        };
      }
    });
    this.set("encryptable", {
      id: 1,
      name: "mate",
      cleartextUsername: "ok",
      cleartextPin: "weird pin",
      cleartextToken: "ilikematebutdonttellanyone",
      description: "The ember email",
      folder: this.folder,
      isFullyLoaded: true
    });
    await render(hbs`<Encryptable::Form @encryptable={{this.encryptable}}/>`);

    assert.equal(this.element.querySelector("#username input").value, "ok");
    assert.dom(this.element.querySelector("#password input")).doesNotExist();
    assert.equal(
      this.element.querySelector("#pin-field input").value,
      "weird pin"
    );
    assert.equal(
      this.element.querySelector("#token input").value,
      "ilikematebutdonttellanyone"
    );
    assert.dom(this.element.querySelector("#email input")).doesNotExist();
    assert
      .dom(this.element.querySelector("input[name='label']"))
      .doesNotExist();
    assert
      .dom(this.element.querySelector("input[name='value']"))
      .doesNotExist();
  });

  test("it adds fields", async function (assert) {
    setLocale("en");

    await render(hbs`<Encryptable::Form />`);

    assert.equal(
      this.element.querySelector("#add-field-dropdown").textContent.trim(),
      "Choose additional field"
    );

    assert
      .dom(this.element.querySelector("input[name='cleartextPin']"))
      .doesNotExist();

    await selectChoose("#add-field-dropdown", "Pin");

    assert.equal(
      this.element.querySelector("#add-field-dropdown").textContent.trim(),
      "Pin"
    );

    //field still shouldnt exist, it gets added when clicking add field button
    assert
      .dom(this.element.querySelector("input[name='cleartextPin']"))
      .doesNotExist();
    //click add field button
    await click("#add-field-button");
    assert.dom(this.element.querySelector("#pin-field input")).exists();

    //dropdown has no field selected
    assert.equal(
      this.element.querySelector("#add-field-dropdown").textContent.trim(),
      "Choose additional field"
    );
  });

  test("it removes fields", async function (assert) {
    setLocale("en");

    await render(hbs`<Encryptable::Form />`);

    assert.dom(this.element.querySelector("#username input")).exists();

    //click remove field button
    await click("#remove-username-field-button");

    assert.dom(this.element.querySelector("#username input")).doesNotExist();
  });

  test("it renames personal-team to users username in encryptable form", async function (assert) {
    setLocale("en");

    await render(hbs`<Encryptable::Form />`);

    await selectChoose(
      "#team-power-select .ember-power-select-trigger",
      "bbteam"
    );

    assert.ok(this.element.textContent.trim().includes("Team"));
    assert.ok(this.element.textContent.trim().includes("bbteam"));

    await selectChoose("#team-power-select .ember-power-select-trigger", "bob");

    assert.ok(this.element.textContent.trim().includes("Team"));
    assert.ok(this.element.textContent.trim().includes("bob"));
  });


  test("Check prefill of team and folder", async function (assert) {
    setLocale("en");

    await render(hbs`<Encryptable::Form />`);

    assert.equal(
      this.element
        .querySelector("#team-power-select .ember-power-select-selected-item")
        .innerText.replace(/\s+/g, " "),
      "bbteam"
    );

    assert.equal(
      this.element
        .querySelector("#folder-power-select .ember-power-select-selected-item")
        .innerText.replace(/\s+/g, " "),
      "bbt"
    );
  });
});
