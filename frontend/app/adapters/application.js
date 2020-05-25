import JSONAPIAdapter from "@ember-data/adapter/json-api";
import { computed } from "@ember/object";
import { pluralize } from "ember-inflector";
import { underscore } from "@ember/string";

export default JSONAPIAdapter.extend({
  namespace: "api",

  pathForType(type) {
    return pluralize(underscore(type));
  },

  headers: computed(function() {
    /* eslint-disable no-undef  */
    return {
      "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content"),
      "content-type": "application/json"
    };
    /* eslint-enable no-undef  */
  })
});
