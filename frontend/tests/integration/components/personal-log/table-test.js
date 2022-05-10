import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";
import { isPresent } from "@ember/utils";

const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return Promise.all([
        {
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
        },
        {
          userId: 2,
          username: "bob",
          event: "update",
          createdAt: "2021-06-15 09:23:02.750627",
          encryptable: {
            get() {
              return 1;
            },
            id: 1
          }
        }
      ]);
    }
  }
});

module("Integration | Component | encryptable/show", function (hooks) {
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
      paperTrailVersions: [
        {
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
        },
        {
          userId: 2,
          username: "bob",
          event: "update",
          createdAt: "2021-06-15 09:23:02.750627",
          encryptable: {
            get() {
              return 1;
            },
            id: 1
          }
        }
      ]
    });
  });
});
