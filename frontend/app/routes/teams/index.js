import Route from "@ember/routing/route";

export default class TeamsIndexRoute extends Route {
  queryParams = {
    team_ids: {
      refreshModel: true
    },
    folder_ids: {
      refreshModel: true
    },
    q: {
      refreshModel: true
    }
  };

  model(params) {
    return this.store.query("team", params);
  }
}
