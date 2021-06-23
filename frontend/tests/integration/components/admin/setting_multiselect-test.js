import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";

const storeStub = Service.extend({
  findAll() {
    return Promise.all([{ value: ["CH", "DE"] }]);
  }
});

module("Integration | Component | admin/setting_multiselect", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
  });

  test("it renders with data", async function (assert) {
    this.set("options", [
      {
        value: "CH",
        label: "Schweiz"
      },
      {
        value: "DE",
        label: "Deutschland"
      }
    ]);

    await render(hbs`<Admin::SettingMultiselect @options={{this.options}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Schweiz"));
    assert.ok(text.includes("Deutschland"));
  });
});
