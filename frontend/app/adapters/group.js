import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  namespace: "api/teams",

  urlForQuery(query, modelName) {

    if (query.team_id) {
      let url =
        `/${this.namespace}/${query.team_id}/${this.pathForType()}`+
        (query.group_id ? `/${query.group_id}` : "");

      delete query.team_id;
      delete query.group_id;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },

  pathForType: function() {
    return "groups";
  }

});
