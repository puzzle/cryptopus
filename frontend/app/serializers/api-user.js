import ApplicationSerializer from "./application";
import { underscore } from "@ember/string";

export default ApplicationSerializer.extend({
  modelNameFromPayloadKey(payloadKey) {
    if (payloadKey === "user/apis" || payloadKey === "team/api_users") {
      return this._super("api-user");
    } else {
      return this._super(payloadKey);
    }
  },

  keyForAttribute(attr) {
    return underscore(attr);
  }
});
