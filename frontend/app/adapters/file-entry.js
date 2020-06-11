import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api/accounts",

  pathForType() {
    return "file_entries";
  },

  urlForCreateRecord(modelName, snapshot) {
    return `/${this.namespace}/${snapshot.belongsTo("account", {
      id: true
    })}/${this.pathForType()}`;
  }
});
