import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | team/show", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    this.set("team", {
      name: "BBT",
      description: "Berufsbildungsteam of Puzzle ITC",
      folders: [
        {
          name: "It-Ninjas",
          accounts: [{ name: "Ninjas account" }]
        }
      ],
      userFavouriteTeams: [{ favourised: true }]
    });

    await render(hbs`<Team::Show @team={{this.team}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("BBT"));
    assert.ok(text.includes("Berufsbildungsteam of Puzzle ITC"));
    assert.ok(text.includes("It-Ninjas"));
  });
});
