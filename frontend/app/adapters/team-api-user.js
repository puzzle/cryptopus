import ApplicationAdapter from "./application";
import { pluralize } from "ember-inflector";

export default class TeamApiUserAdapter extends ApplicationAdapter {
  pathForType(modelName) {
    let snakeCased = modelName.replace("-", "_");
    return pluralize(snakeCased);
  }

  urlForQuery(query, modelName) {
    let teamId = query.teamId;
    if (teamId) {
      delete query.teamId;
      return `/${this.namespace}/teams/${teamId}/api_users`;
    }
    return super.urlForQuery(query, modelName);
  }
}
