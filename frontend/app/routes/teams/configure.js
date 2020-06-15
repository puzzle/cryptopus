import Route from "@ember/routing/route";

export default class TeamsConfigureRoute extends Route {
  async model(params) {
    return params.team_id;
  }
}
