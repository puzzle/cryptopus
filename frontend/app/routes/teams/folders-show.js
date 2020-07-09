import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default class TeamsFoldersIndexRoute extends Route {
  @service navService;

  templateName = "teams/index";

  afterModel(_resolvedModel, transition) {
    this.navService.setSelectedTeamById(transition.to.params.team_id);
    this.navService.setSelectedFolderById(transition.to.params.folder_id);
  }

  model(params) {
    return this.store.query("team", params);
  }
}
