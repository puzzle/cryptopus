import RESTAdapter from "@ember-data/adapter/rest";
import { computed } from "@ember/object";

export default RESTAdapter.extend({
  namespace: "api",

  headers: computed(function() {
    /* eslint-disable no-undef  */
    return {
      "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
    };
    /* eslint-enable no-undef  */
  })
});
