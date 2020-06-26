import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default class TeamsIndexRoute extends Route {
  @service navService;

  queryParams = {
    team_id: {
      refreshModel: true
    },
    folder_id: {
      refreshModel: true
    },
    q: {
      refreshModel: true
    }
  };

  afterModel(_resolvedModel, transition) {
    let team_id = transition.to.queryParams.team_id;
    let folder_id = transition.to.queryParams.folder_id;
    if (team_id) {
      this.navService.selectedTeam = this.store.peekRecord("team", team_id);
    } else {
      this.navService.selectedTeam = null;
    }
    if (folder_id) {
      this.navService.selectedFolder = this.store.peekRecord(
        "folder",
        folder_id
      );
    } else {
      this.navService.selectedFolder = null;
    }
  }

  model(params) {
    return this.store.query("team", params);
  }
}
