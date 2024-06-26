import JSONAPIAdapter from "@ember-data/adapter/json-api";
import { pluralize } from "ember-inflector";
import { underscore } from "@ember/string";
import ENV from "../config/environment";

export default class ApplicationAdapter extends JSONAPIAdapter {
  namespace = "api";

  pathForType(type) {
    return pluralize(underscore(type));
  }

  get headers() {
    return {
      "X-CSRF-Token": ENV.CSRFToken,
      "content-type": "application/json"
    };
  }
}
