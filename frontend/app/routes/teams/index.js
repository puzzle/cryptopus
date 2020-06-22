import Route from "@ember/routing/route";

export default class TeamsIndexRoute extends Route {
  queryParams = {
    team_id: {
      refreshModel: true
    },
    folder_id: {
      refreshModel: true
    },
    q: {
      refreshModel: true
    }
  };

  model(params) {
    this.store.findRecord("account", 67);
    return this.store.query("team", params);
  }
}
