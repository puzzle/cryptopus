import ApplicationAdapter from "./application";

export default class UserHumanAdapter extends ApplicationAdapter {
  pathForType() {
    return "user_humen";
  }

  urlForQuery(query, modelName) {
    if (query.candidates && query.teamId != null) {
      let url = `/${this.namespace}/user_candidates?team_id=${query.teamId}`;
      delete query.candidates;
      delete query.teamId;
      return url;
    }
    if (query.candidates && query.teamId == null) {
      let url = `/${this.namespace}/user_candidates`;
      delete query.candidates;
      delete query.teamId;
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
