import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  namespace: "api/teams",

  urlForQuery(query, modelName) {

    if (query.teamId) {
      let url =
        `/${this.namespace}/${query.teamId}/${this.pathForType()}`+
        (query.groupId ? `/${query.groupId}` : "");

      delete query.teamId;
      delete query.groupId;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },

  pathForType: function() {
    return "groups";
  }

});
