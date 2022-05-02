import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";

const navServiceStub = Service.extend();

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

module("Integration | Component | folder/form", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    this.owner.unregister("service:navService");
    this.owner.register("service:navService", navServiceStub);
    setLocale("en");
  });

  test("it renders without input data", async function (assert) {
    await render(hbs`<Folder::Form />`);

    assert.ok(this.element.textContent.trim().includes("Folder name"));
    assert.ok(this.element.textContent.trim().includes("Description"));
    assert.ok(this.element.textContent.trim().includes("Save"));
    assert.ok(this.element.textContent.trim().includes("Close"));
  });

  test("it renders with input data", async function (assert) {
    this.set("folder", {
      id: 1,
      name: "mail",
      description: "The ember email"
    });
    await render(hbs`<Folder::Form \@folder\=\{{this.folder}}/>`);

    assert.equal(
      this.element.querySelector("input[name='foldername']").value,
      "mail"
    );

    assert.equal(
      this.element.querySelector("textarea").value,
      "The ember email"
    );
  });
});
