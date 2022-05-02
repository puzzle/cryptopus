import { inject as service } from "@ember/service";
import BaseRoute from "../base";
import { action } from "@ember/object";

export default class TeamsFoldersIndexRoute extends BaseRoute {
  @service navService;

  templateName = "teams/index";

  afterModel(_resolvedModel, transition) {
    this.navService.setSelectedTeamById(transition.to.params.team_id);
    this.navService.setSelectedFolderById(transition.to.params.folder_id);
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
