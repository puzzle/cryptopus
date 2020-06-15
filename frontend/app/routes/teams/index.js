import Route from "@ember/routing/route";

export default class TeamsIndexRoute extends Route {
  model(params) {
    return this.store.query("team", params);
  }
}
