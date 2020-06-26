import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api/accounts",

  pathForType() {
    return "file_entries";
  },

  urlForQuery(query, modelName) {
    if (query.accountId) {
      let url = `/${this.namespace}/${query.accountId}/${this.pathForType()}`;

      delete query.accountId;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },

  urlForCreateRecord(modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("account", {
      id: true
    })}/${this.pathForType()}`;
  },

  urlForDeleteRecord(id, _modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("account", {
      id: true
    })}/${this.pathForType()}/${id}`;
  }
});
