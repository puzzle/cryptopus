import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";

const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return [
        {
          filename: "file1",
          description: "description for file1",
          account: {
            get() {
              return 1;
            }
          }
        },
        {
          filename: "file2",
          description: "description for file2",
          account: {
            get() {
              return 2;
            }
          }
        }
      ];
    }
  }
});

module("Integration | Component | account-show", function(hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function() {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it renders with data", async function(assert) {
    this.set("account", {
      id: 1,
      accountname: "Ninjas test account",
      description: "Account for the ninjas",
      cleartextUsername: "mail",
      cleartextPassword: "e2jd2rh4g5io7"
    });
    await render(hbs`<AccountShow @account={{this.account}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Ninjas test account"));
    assert.ok(text.includes("Account for the ninjas"));
    assert.ok(text.includes("file1"));
    assert.ok(text.includes("description for file1"));
    assert.ok(text.includes("file2"));
    assert.ok(text.includes("description for file2"));
  });
});
