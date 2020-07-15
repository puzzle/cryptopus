import BaseRoute from "../base";

export default class TeamsConfigureRoute extends BaseRoute {
  async model(params) {
    return params.team_id;
  }
}
