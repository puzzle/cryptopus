import ApplicationAdapter from "./application";

export default class UserHumanAdapter extends ApplicationAdapter {
  pathForType() {
    return "user_humen";
  }

  urlForQuery(query, modelName) {
    if (query.teamId && query.candidates) {
      let url = `/${this.namespace}/teams/${query.teamId}/candidates`;
      delete query.teamId;
      delete query.candidates;
      return url;
    }
    if (query.admin) {
      let url = `/${this.namespace}/admin/users`;
      delete query.admin;
      return url;
    }
    return super.urlForQuery(query, modelName);
  }

  urlForUpdateRecord(id) {
    return `/${this.namespace}/admin/users/${id}`;
  }

  urlForDeleteRecord(id) {
    return `/${this.namespace}/admin/users/${id}`;
  }

  urlForCreateRecord() {
    return `/${this.namespace}/admin/users`;
  }
}
