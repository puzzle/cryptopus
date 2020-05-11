import ApplicationAdapter from "./application";
import { pluralize } from "ember-inflector";

export default ApplicationAdapter.extend({
  pathForType(modelName) {
    let snake_cased = modelName.replace("-", "_");
    return pluralize(snake_cased);
  },

  urlForQuery(query, modelName) {
    let teamId = query.teamId;
    if (teamId) {
      delete query.teamId;
      return `/${this.namespace}/teams/${teamId}/api_users`;
    }
    return super.urlForQuery(query, modelName);
  }
});
