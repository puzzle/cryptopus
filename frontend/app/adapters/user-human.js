import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  pathForType() {
    return "user_humen";
  },

  urlForQuery(query, modelName) {
    if (query.teamId && query.candidates) {
      let url = `/${this.namespace}/teams/${query.teamId}/candidates`;
      delete query.teamId;
      delete query.candidates;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },
})
