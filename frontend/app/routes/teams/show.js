import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import ApplicationRoute from "../application";

export default class TeamsShowRoute extends ApplicationRoute {
  @service navService;
  @service notify;
  @service intl;

  templateName = "teams/index";
  controllerName = "teams/index";

  afterModel(_resolvedModel, transition) {
    this.navService.setSelectedTeamById(transition.to.params.team_id);
    this.navService.selectedFolder = null;
    this.navService.clearSearch();
  }

  model(params) {
    return this.store.query("team", params);
  }

  @action
  loading() {
    return false;
  }
}
