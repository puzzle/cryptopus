import ApplicationSerializer from "./application";

export default ApplicationSerializer.extend({
  serialize() {
    let json = this._super(...arguments);
    json.data.attributes.type = "credentials";
    return json;
  }
});
