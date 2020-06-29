import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class NavBarComponent extends Component {
  @service router;

  @tracked
  isNewAccount = false;

  @tracked
  isNewFolder = false;

  @tracked
  isNewTeam = false;

  get isStartpage() {
    return this.router.currentRouteName === "index";
  }

  @action
  toggleAccountCreating() {
    this.isNewAccount = !this.isNewAccount;
  }

  @action
  toggleFolderCreating() {
    this.isNewFolder = !this.isNewFolder;
  }

  @action
  toggleTeamCreating() {
    this.isNewTeam = !this.isNewTeam;
  }

  @action
  searchByQuery() {
    if (this.searchQuery.trim(' ').length > 2){
      this.router
        .transitionTo("teams.index", {
          queryParams: { q: this.searchQuery, team_id: undefined, folder_id: undefined }
      })
        .then(() => {
          this.collapsed = false;
        });
    }
  }
}
