import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";
import Service from "@ember/service";

const storeStub = Service.extend({
  findAll() {
    return Promise.all([{ value: ["192.168.12.21"] }]);
  }
});

module(
  "Integration | Component | admin/setting-multiselect-with-create",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      this.owner.unregister("service:store");
      this.owner.register("service:store", storeStub);
    });

    hooks.beforeEach(function () {
      setLocale("en");
    });

    test("it renders with data", async function (assert) {
      await render(hbs`<Admin::SettingMultiselectWithCreate/>`);

      let text = this.element.textContent.trim();
      assert.ok(text.includes("192.168.12.21"));
    });
  }
);
