import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | changelog", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders", async function (assert) {
    await render(hbs`<Changelog />`);

    assert.ok(this.element.textContent.trim(), "non-empty content");

    // Template block usage:
    await render(hbs`
      <Changelog>
      </Changelog>
    `);

    const text = this.element.textContent.trim();
    assert.equal(text.match("Version 4.1").length === 1, true);
  });
});
