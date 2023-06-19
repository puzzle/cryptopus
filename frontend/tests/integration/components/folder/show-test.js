import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";

const navServiceStub = Service.extend();

module("Integration | Component | folder/show", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:navService");
    this.owner.register("service:navService", navServiceStub);
  });

  test("it renders with data", async function (assert) {
    const folder = {
      id: 1,
      name: "Inbox",
      isInboxFolder: false,

      get(key) {
        if (key === "isInboxFolder") {
          return false;
        }
      }
    };

    this.set("folder", folder);

    this.set("encryptable", {
      id: 1,
      name: "Ninjas encryptable credentials",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      sender_name: "Bob Kuchen (bob)",
      folder: folder
    });

    await render(hbs`<Folder::Show @folder={{this.folder}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Inbox"));
  });
});
