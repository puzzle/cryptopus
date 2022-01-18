import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | file-entry/row", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    this.set("fileEntry", {
      filename: "file1",
      description: "description for file1",
      encryptable: {
        get() {
          return 1;
        }
      }
    });

    await render(hbs`<FileEntry::Row @fileEntry={{this.fileEntry}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("file1"));
    assert.ok(text.includes("description for file1"));
  });
});
