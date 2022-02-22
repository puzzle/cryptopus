import JSONAPIAdapter from "@ember-data/adapter/json-api";
import { computed } from "@ember/object";
import { pluralize } from "ember-inflector";
import { underscore } from "@ember/string";
import ENV from "../config/environment";

export default class ApplicationAdapter extends JSONAPIAdapter {
  namespace = "api"

  pathForType(type) {
    return pluralize(underscore(type));
  }

  headers = computed(function () {
    /* eslint-disable no-undef  */
    return {
      "X-CSRF-Token": ENV.CSRFToken,
      "content-type": "application/json"
    };
    /* eslint-enable no-undef  */
  })
}

