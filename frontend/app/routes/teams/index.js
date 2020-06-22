import Route from "@ember/routing/route";

export default class TeamsIndexRoute extends Route {
  model(params) {
    this.store.findRecord("account", 67);
    return this.store.query("team", params);
  }
}
