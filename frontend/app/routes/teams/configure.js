import ApplicationRoute from "../application";

export default class TeamsConfigureRoute extends ApplicationRoute {
  async model(params) {
    return params.team_id;
  }
}
