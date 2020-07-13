import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class NavService extends Service {
  @tracked selectedTeam = null;
  @tracked selectedFolder = null;

  @tracked isShowingFavourites;
  @tracked availableTeams = [];

  @service store;

  get sortedTeams() {
    return this.availableTeams.toArray().sort((a, b) => {
      if (a.name < b.name) return -1;
      if (a.name > b.name) return 1;
      return 0;
    });
  }

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
