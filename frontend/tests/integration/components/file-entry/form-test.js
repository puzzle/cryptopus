import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";
import { selectFiles } from "ember-file-upload/test-support";

module("Integration | Component | file-entry/form", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders", async function (assert) {
    await render(hbs`<FileEntry::Form />`);

    let file = new File(
      ["I can feel the money leaving my body"],
      "douglas_coupland.txt",
      { type: "text/plain" }
    );
    await selectFiles("#upload-file", file);

    assert.ok(this.element.textContent.trim().includes("douglas_coupland.txt"));
    assert.ok(
      this.element.textContent.trim().includes("Select a different file.")
    );
  });
});
