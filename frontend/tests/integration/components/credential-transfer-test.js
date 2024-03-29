import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";
import Notify from "ember-notify";
import { isPresent } from "@ember/utils";

const storeStub = Service.extend({
  createRecord() {
    return {
      receiver_id: null
    };
  },
  query(modelName) {
    if (modelName === "user-human") {
      return Promise.all([
        {
          username: "Bob",
          givenname: "Bobby",
          role: "admin",
          lastLoginAt: "11.03.2022 03:03",
          lastLoginFrom: "111.123.22.2",
          auth: "db",
          providerUid: 2,
          isDeleted: false
        }
      ]);
    }
  }
});

const notifyStub = Notify.extend({
  alert(message, options) {
    options.closeAfter = null;
    return this.show("alert", message, options);
  }
});

const users = [
  {
    username: "Bob",
    givenname: "Bobby",
    role: "admin",
    lastLoginAt: "11.03.2022 03:03",
    lastLoginFrom: "111.123.22.2",
    auth: "db",
    providerUid: 2,
    isDeleted: false
  },
  {
    username: "Alice",
    givenname: "Allison",
    role: "user",
    lastLoginAt: "12.03.2022 06:56",
    lastLoginFrom: "111.123.22.1",
    auth: "db",
    providerUid: 1,
    isDeleted: false
  },
  {
    username: "Fred",
    isDeleted: true
  }
];

module("Integration | Component | credential-transfer", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    this.owner.unregister("service:notify");
    this.owner.register("service:notify", notifyStub);
    setLocale("en");
  });

  test("it renders pop up and chooses receiver", async function (assert) {
    this.set("user-human", users);
    this.set("encryptableName", "Invoice");

    await render(
      hbs`<CredentialTransfer @encryptableName={{this.encryptableName}} />`
    );

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Share credentials with"));
    assert.ok(text.includes("A copy of"));
    assert.ok(text.includes("Invoice"));
    assert.ok(text.includes("will be sent to the receiver's inbox"));
    assert.ok(text.includes("Send"));

    let saveButton = this.element.querySelector('button[alt="save"]');
    assert.ok(isPresent(saveButton));
  });
});
