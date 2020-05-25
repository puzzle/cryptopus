import { module, test } from "qunit";
import { setupTest } from "ember-qunit";

module("Unit | Serializer | application", function(hooks) {
  setupTest(hooks);

  test("it exists", function(assert) {
    let store = this.owner.lookup("service:store");
    let serializer = store.serializerFor("application");

    assert.ok(serializer);
  });

  test("it serializes group", function(assert) {
    let store = this.owner.lookup("service:store");
    let team = store.createRecord("team", { id: 2 });
    let group = store.createRecord("group", {
      name: "bbt",
      team: team
    });

    let serializedRecord = group.serialize();

    assert.equal(serializedRecord.data.attributes.name, "bbt");
  });
});
