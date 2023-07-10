import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";
import { setLocale } from "ember-intl/test-support";
import { isPresent } from "@ember/utils";

const storeStub = Service.extend({
  createRecord() {
    return {
      receiver_id: null,
      filename: null,
      description: null,
      content_type: "text/plain"
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

module("Integration | Component | file-transfer", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it uploads file and show notify alert", async function (assert) {
    this.set("user-human", users);

    await render(hbs`<FileTransfer />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Send file to"));
    assert.ok(
      text.includes(
        "Your file will be sent encrypted to the inbox folder from the selected receiver."
      )
    );
    assert.ok(text.includes("Choose a file"));
    assert.ok(text.includes("File to upload"));
    assert.ok(text.includes("Description for the receiver"));
    assert.ok(text.includes("Send"));

    let saveButton = this.element.querySelector('button[alt="save"]');
    assert.ok(isPresent(saveButton));
  });
});
