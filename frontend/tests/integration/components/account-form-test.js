import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { clickTrigger } from "ember-power-select/test-support/helpers";
import { selectChoose } from "ember-power-select/test-support";
import { setLocale } from "ember-intl/test-support";

const storeStub = Service.extend({
  findAll(modelName) {
    if (modelName === "folder") {
      return Promise.all([
        {
          id: 1,
          name: "bbt",
          team: {
            get() {
              return 1;
            }
          }
        }
      ]);
    } else if (modelName === "team") {
      return Promise.all([
        {
          id: 1,
          name: "supporting",
          description: "supporting folders",
          folder: [1]
        }
      ]);
    }
  },
  createRecord() {
    return { folder: null, isNew: true };
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
  }
});

module("Integration | Component | account-form", function(hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function() {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it renders without input data", async function(assert) {
    await render(hbs`<AccountForm />`);

    await selectChoose(
      "#team-power-select .ember-power-select-trigger",
      "supporting"
    );

    await clickTrigger("#folder-power-select");

    assert.equal(
      this.element.querySelector(".ember-power-select-dropdown").innerText,
      "bbt"
    );

    assert.ok(this.element.textContent.trim().includes("Accountname"));
    assert.ok(this.element.textContent.trim().includes("Team"));
    assert.ok(this.element.textContent.trim().includes("Username"));
    assert.ok(this.element.textContent.trim().includes("Folder"));
    assert.ok(this.element.textContent.trim().includes("Password"));
    assert.ok(this.element.textContent.trim().includes("Description"));
    assert.ok(this.element.textContent.trim().includes("Save"));
    assert.ok(this.element.textContent.trim().includes("Close"));
  });

  test("it renders with input data", async function(assert) {
    this.set("folder", {
      id: 1,
      name: "bbt",
      get() {
        return 1;
      }
    });
    this.set("account", {
      id: 1,
      accountname: "mail",
      cleartextUsername: "mail@ember.com",
      cleartextPassword: "lol",
      description: "The ember email",
      folder: this.get("folder")
    });
    await render(hbs`<AccountForm \@account\=\{{this.account}}/>`);

    assert.equal(
      this.element.querySelector("input[name=accountname]").value,
      "mail"
    );
    assert.equal(
      this.element.querySelector("input[name=cleartextUsername]").value,
      "mail@ember.com"
    );
    assert.equal(
      this.element.querySelector("textarea[name=description]").value,
      "The ember email"
    );
    assert.ok(this.element.textContent.trim().includes("supporting"));
    assert.ok(this.element.textContent.trim().includes("bbt"));
  });
});
