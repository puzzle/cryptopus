import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module("Integration | Component | admin/setting_multiselect", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    setLocale("en");
  });

  test("it renders without data", async function (assert) {
    await render(hbs`<Admin::SettingMultiselect />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Whitelisted Countries"));
  });

  test("it renders with data", async function (assert) {
    this.set("countries", {
      key: "country_source_whitelist",
      value: ["CH", "DE", "SL", "US"]
    });

    this.set("ips", {
      key: "ip_whitelist",
      value: ["0.0.0.0", "192.168.10.0", "192.168.255.0"]
    });

    await render(hbs`<Admin::SettingMultiselect @options={{this.countries}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("CH"));
    assert.ok(text.includes("DE"));
    assert.ok(text.includes("SL"));
    assert.ok(text.includes("US"));
  });
});
