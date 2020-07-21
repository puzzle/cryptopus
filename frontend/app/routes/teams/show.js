import { inject as service } from "@ember/service";
import BaseRoute from "../base";

export default class TeamsShowRoute extends BaseRoute {
  @service navService;
  @service notify;
  @service intl;

  templateName = "teams/index";

  afterModel(_resolvedModel, transition) {
    this.navService.setSelectedTeamById(transition.to.params.team_id);
    this.navService.selectedFolder = null;
    this.navService.searchQuery = null;
  }

  model(params) {
    return this.store.query("team", params);
  }
}
