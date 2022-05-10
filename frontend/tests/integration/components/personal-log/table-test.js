import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";

const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return Promise.all({
        userId: 1,
        username: "alice",
        event: "viewed",
        createdAt: "2021-06-14 09:23:02.750627",
        encryptable: {
          get() {
            return 1;
          },
          id: 1
        }
      });
    }
  }
});

module("Integration | Component | personal-log/table", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
    this.set("encryptable", {
      id: 1,
      name: "Ninjas test encryptable",
      description: "Encryptable for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7",
      createdAt: "2021-06-14 09:23:02.750627",
      updatedAt: "2021-06-22 11:33:13.766879",
      paperTrailVersions: {
        userId: 1,
        username: "alice",
        event: "viewed",
        createdAt: "2021-06-14 09:23:02.750627",
        encryptable: {
          get() {
            return 1;
          },
          id: 1
        }
      }
    });
  });
  test("it renders with data", async function (assert) {
    await render(
      hbs`<Personal-Log::TableRow @paperTrailVersion={{this.encryptable.paperTrailVersions}}/>`
    );
    let text = this.element.textContent.trim();
    assert.ok(text.includes("14.06.2021 09:23"));
    assert.ok(text.includes("viewed"));
  });
});
