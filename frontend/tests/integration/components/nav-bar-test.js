import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import Service from "@ember/service";
import { hbs } from "ember-cli-htmlbars";

const storeStub = Service.extend({
  query() {
    return Promise.all([
      {
        id: 1,
        name: "team1",
        private: false,
        description: "team1 desc",
        folders: [
          {
            id: 1,
            name: "folder1"
          },
          {
            id: 2,
            name: "folder2"
          }
        ]
      },
      {
        id: 2,
        name: "team2",
        private: false,
        description: "team2 desc"
      }
    ]);
  }
});

module("Integration | Component | nav-bar", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders", async function (assert) {
    this.owner.unregister("service:store");
    this.owner.register("service:store", storeStub);
    await render(hbs`<NavBar />`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("help"));
  });
});
