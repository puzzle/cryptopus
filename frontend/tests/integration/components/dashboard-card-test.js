import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | dashboard-card", function (hooks) {
  setupRenderingTest(hooks);

  const team = {
    id: 1,
    name: "GitHub"
  };

  test("it renders", async function (assert) {
    this.set("team", team);

    await render(hbs`<DashboardCard />`);

    assert.equal(this.element.textContent.trim(), "");

    // Template block usage:
    await render(hbs`
      <DashboardCard @team={{this.team}}>
      </DashboardCard>
    `);

    assert.equal(this.element.textContent.trim(), "GitHub");
  });
});
