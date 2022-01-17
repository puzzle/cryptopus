import ApplicationSerializer from "./application";

export default ApplicationSerializer.extend({
  serialize(snapshot) {
    let json = this._super(...arguments);
    let type = "credentials";
    if (snapshot.modelName === "encryptable-ose-secret") {
      type = "ose_secret";
    }
    json.data.attributes.type = type;
    return json;
  }
});
