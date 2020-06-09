import { module, test } from "qunit";
import { setupTest } from "ember-qunit";

module("Unit | Serializer | application", function(hooks) {
  setupTest(hooks);

  test("it exists", function(assert) {
    let store = this.owner.lookup("service:store");
    let serializer = store.serializerFor("application");

    assert.ok(serializer);
  });

  test("it serializes folder", function(assert) {
    let store = this.owner.lookup("service:store");
    let team = store.createRecord("team", { id: 2 });
    let folder = store.createRecord("folder", {
      name: "bbt",
      team: team
    });

    let serializedRecord = folder.serialize();

    assert.equal(serializedRecord.data.attributes.name, "bbt");
  });
});
