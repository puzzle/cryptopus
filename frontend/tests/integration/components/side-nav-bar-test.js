import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";

import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | side-nav-bar", function(hooks) {
  setupRenderingTest(hooks);

  test("it renders", async function(assert) {
    this.set("teams", [{
      id: 1,
      name: "team1",
      private: false,
      description: "team1 desc",
      folders: [{
        id: 1,
        name: "folder1"
      }, {
        id: 2,
        name: "folder2"
      }]
    }, {
      id: 2,
      name: "team2",
      private: false,
      description: "team2 desc"
    }
    ]);
    await render(hbs`<SideNavBar @teams={{this.teams}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("All Teams"));
    assert.ok(text.includes("team1"));
    assert.ok(text.includes("team2"));
  });
});
