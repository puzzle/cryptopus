import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api",

  pathForType() {
    return "personal_logs";
  },

  urlForQuery(query) {
    if (query.encryptableId) {
      let url = `/${this.namespace}/encryptables/${query.encryptableId}/logs`;

      delete query.encryptableId;
      return url;
    } else {
      let url = `/${this.namespace}/personal_logs`;
      return url;
    }
  }
});
