import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default class TeamsShowRoute extends Route {
  @service navService;

  templateName = "teams/index";

  afterModel(_resolvedModel, transition) {
    this.navService.setSelectedTeamById(transition.to.params.team_id);
    this.navService.selectedFolder = null;
  }

  model(params) {
    return this.store.query("team", params);
  }
}
