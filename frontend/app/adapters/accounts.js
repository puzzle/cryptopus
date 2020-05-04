import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  namespace: "api/accounts",

  buildUrl(modelName, id, snapshot, requestType, query) {
    // if (requestType === "query" && query.team_id) {
    //   let url =
    //   `/${this.namespace}/${query.team_id}/${this.pathForType()}`
    // }

    return super.buildUrl(modelName, id, snapshot, requestType, query)
  }
});
