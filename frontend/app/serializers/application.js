import JSONAPISerializer from "@ember-data/serializer/json-api";
import { underscore } from "@ember/string";

export default class ApplicationSerializer extends JSONAPISerializer {
  keyForAttribute(attr) {
    return underscore(attr);
  }

  keyForRelationship(key) {
    return underscore(key);
  }

  // serializeBelongsTo(snapshot, json, relationship) {
  //   // do not serialize the attribute!
  //   if (relationship.options && relationship.options.readOnly) {
  //     return;
  //   }
  //   this._super(...arguments);
  // }
}
