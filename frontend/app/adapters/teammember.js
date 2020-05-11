import ApplicationAdapter from "./application";

export default ApplicationAdapter.extend({
  namespace: "api/teams",

  urlForQuery(query, modelName) {
    if (query.teamId) {
      let url = `/${this.namespace}/${query.teamId}/${this.pathForType()}`;
      url +=
        query.route === "candidates"
          ? "/candidates"
          : query.memberId
          ? `/${query.memberId}`
          : "";
      delete query.teamId;
      delete query.memberId;
      delete query.route;
      return url;
    }
    return super.urlForQuery(query, modelName);
  },

  pathForType() {
    return "members";
  },

  urlForCreateRecord(modelName, snapshot) {
    return `/${this.namespace}/${snapshot.attr(
      "teamId"
    )}/${this.pathForType()}`;
  },

  urlForDeleteRecord(id, modelName, snapshot) {
    return `/${this.namespace}/${snapshot.attr(
      "teamId"
    )}/${this.pathForType()}/${id}`;
  }
});
