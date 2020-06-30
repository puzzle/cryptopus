import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default Service.extend({
  @tracked selectedTeam: null,
  @tracked selectedFolder: null,
  @tracked searchQuery: null
});
export default class NavService extends Service {
  @tracked selectedTeam = null;
  @tracked selectedFolder = null;

  @service store;

  clear() {
    this.selectedTeam = null;
    this.selectedFolder = null;
  }

  setSelectedTeamById(team_id) {
    this.selectedTeam = team_id ? this.store.peekRecord("team", team_id) : null;
  }

  setSelectedFolderById(folder_id) {
    this.selectedFolder = folder_id
      ? this.store.peekRecord("folder", folder_id)
      : null;
  }
}
