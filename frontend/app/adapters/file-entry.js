import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api/encryptables",

  pathForType() {
    return "file_entries";
  },

  urlForQuery(query, modelName) {
    if (query.encryptableId) {
      let url = `/${this.namespace}/${
        query.encryptableId
      }/${this.pathForType()}`;

      delete query.encryptableId;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },

  urlForCreateRecord(modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("encryptable", {
      id: true
    })}/${this.pathForType()}`;
  },

  urlForDeleteRecord(id, _modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("encryptable", {
      id: true
    })}/${this.pathForType()}/${id}`;
  }
});
