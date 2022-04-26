import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api/encryptables",

  pathForType() {
    return "logs";
  },

  urlForQuery(query, modelName) {
    if (query.encryptableId) {
      let url = `/${this.namespace}/${query.encryptableId}/logs`;

      delete query.encryptableId;
      return url;
    }
    return super.urlForQuery(query, modelName);
  }
});
