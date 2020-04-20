import RESTAdapter from "@ember-data/adapter/rest";
import { computed } from "@ember/object";

export default RESTAdapter.extend({
  namespace: "api",

  headers: computed(function() {
    /* eslint-disable ember/no-global-jquery, no-undef, ember/no-jquery  */
    return {
      "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
    };
    /* eslint-enable no-global-jquery, no-undef, no-jquery  */
  })
});
