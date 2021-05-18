import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | team/form", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders without input data", async function (assert) {
    await render(hbs`<Team::Form />`);

    assert.ok(this.element.textContent.trim().includes("Name"));
    assert.ok(this.element.textContent.trim().includes("Private"));
    assert.ok(this.element.textContent.trim().includes("Description"));
    assert.ok(this.element.textContent.trim().includes("Save"));
    assert.ok(this.element.textContent.trim().includes("Close"));
  });

  test("it renders with input data", async function (assert) {
    this.set("team", {
      id: 1,
      name: "mail",
      private: false,
      description: "The ember email"
    });
    await render(hbs`<Team::Form \@team\=\{{this.team}}/>`);

    assert.equal(
      this.element.querySelector("input[name='teamname']").value,
      "mail"
    );
    assert.equal(
      this.element.querySelector("input[name=private]").checked,
      false
    );
    assert.equal(
      this.element.querySelector("textarea").value,
      "The ember email"
    );
  });
});
