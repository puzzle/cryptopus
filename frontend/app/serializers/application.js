import RESTSerializer from "@ember-data/serializer/rest";
import { underscore } from "@ember/string";

export default RESTSerializer.extend({
  normalizeResponse(store, primaryModelClass, payload, id, requestType) {
    payload = payload.data || payload;
    return this._super(store, primaryModelClass, payload, id, requestType);
  },

  serializeBelongsTo(snapshot, json, relationship) {
    let key = relationship.key + "_id";
    var belongsTo = snapshot.belongsTo(relationship.key);

    json[key] = belongsTo.record.id;
  },

  keyForAttribute(attr) {
    return underscore(attr);
  }
});
