import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import Service from "@ember/service";

const navServiceStub = Service.extend();

module("Integration | Component | team/show", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:navService");
    this.owner.register("service:navService", navServiceStub);
  });

  test("it renders with data", async function (assert) {
    this.set("team", {
      name: "BBT",
      description: "Berufsbildungsteam of Puzzle ITC",
      folders: [
        {
          name: "It-Ninjas",
          encryptables: [{ name: "Ninjas encryptable" }]
        }
      ],
      encryptionAlgorithm: "AES256",
      encryptionAlgorithmImageName: "aes-256",
      userFavouriteTeams: [{ favourised: true }]
    });

    await render(hbs`<Team::Show @team={{this.team}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("BBT"));
    assert.ok(text.includes("Berufsbildungsteam of Puzzle ITC"));
    assert.ok(text.includes("It-Ninjas"));

    let image = this.element.querySelector("img.encryption-label");
    assert.ok(image.getAttribute("src").includes("aes-256.svg"));
  });
});
