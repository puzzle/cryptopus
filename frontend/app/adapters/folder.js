import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api/teams",

  urlForQuery(query, modelName) {
    if (query.teamId) {
      let url = `/${this.namespace}/${query.teamId}/${this.pathForType()}`;

      delete query.teamId;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },


  /* eslint-disable no-unused-vars */
  urlForFindRecord(id, modelName, snapshot) {
    return `/api/${this.pathForType()}/${id}`;
  },

  urlForCreateRecord(modelName, snapshot) {
    return `/api/${this.pathForType()}`;
  },

  urlForUpdateRecord(id, modelName, snapshot) {
    return `/api/${this.pathForType()}/${id}`;
  },
  /* eslint-enable no-unused-vars */


  pathForType: function() {
    return "folders";
  }
});
