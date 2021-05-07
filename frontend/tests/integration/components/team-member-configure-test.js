import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";
import Service from "@ember/service";

const storeStub = Service.extend({
  query(modelName, params) {
    if (params) {
      return Promise.all([
        { label: "Bob", admin: true, deletable: false },
        { label: "Alice", admin: false, deletable: true }
      ]);
    }
  }
});

module("Integration | Component | team-member-configure", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    setLocale("en");
  });

  test("it renders without data", async function (assert) {
    await render(hbs`<TeamMemberConfigure />`);

    assert.ok(
      this.element.textContent
        .trim()
        .includes("Edit Team Members and Api Users")
    );
    assert.ok(this.element.textContent.trim().includes("Members"));
    assert.ok(this.element.textContent.trim().includes("Api Users"));
    assert.ok(this.element.textContent.trim().includes("User"));
    assert.ok(this.element.textContent.trim().includes("Description"));
    assert.ok(this.element.textContent.trim().includes("Enabled"));
  });

  test("it renders with data", async function (assert) {
    await render(hbs`<TeamMemberConfigure @teamId="1"/>`);

    assert.ok(this.element.textContent.trim().includes("Bob"));
    assert.ok(this.element.textContent.trim().includes("Alice"));
  });
});
