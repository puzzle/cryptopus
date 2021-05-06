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

  urlForQueryRecord(query, modelName) {
    if (query.teamId) {
      let url = `/${this.namespace}/${query.teamId}/${this.pathForType()}/${
        query.id
      }`;
      delete query.teamId;
      return url;
    }
    return super.urlForQueryRecord(query, modelName);
  },

  urlForCreateRecord(modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("team", {
      id: true
    })}/${this.pathForType()}`;
  },

  urlForUpdateRecord(id, modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("team", {
      id: true
    })}/${this.pathForType()}/${id}`;
  },

  urlForDeleteRecord(id, modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("team", {
      id: true
    })}/${this.pathForType()}/${id}`;
  },

  pathForType: function () {
    return "folders";
  }
});
