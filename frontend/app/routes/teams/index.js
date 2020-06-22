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
    let team_ids = transition.to.queryParams.team_ids;
    let folder_id = transition.to.queryParams.folder_id;
    if (team_ids) {
      this.navService.selectedTeam = this.store.peekRecord("team", team_ids);
    }
    if (folder_id) {
      this.navService.selectedFolder = this.store.peekRecord(
        "folder",
        folder_id
      );
    }
  }

  model(params) {
    this.store.findRecord("account", 67);
    return this.store.query("team", params);
  }
}
