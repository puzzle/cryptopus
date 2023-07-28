import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import ENV from "../config/environment";

export default class NavBarComponent extends Component {
  @service router;
  @service navService;
  @service screenWidthService;
  @service userService;

  searchInterval;

  @tracked
  isNewEncryptableCredential = false;

  @tracked
  isNewEncryptableFile = false;

  @tracked
  isNewFolder = false;

  @tracked
  isNewTeam = false;

  @tracked
  isFileSharing = false;

  get isStartpage() {
    return this.router.currentRouteName === "index";
  }

  get givenname() {
    return ENV.currentUserGivenname;
  }

  @action
  setNavbarCollapsed(isCollapsed) {
    this.navService.isNavbarCollapsed = isCollapsed;
  }

  @action
  toggleEncryptableCredentialCreating() {
    this.isNewEncryptableCredential = !this.isNewEncryptableCredential;
  }

  @action
  toggleEncryptableFileCreating() {
    this.isNewEncryptableFile = !this.isNewEncryptableFile;
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
  toggleFileSharing() {
    this.isFileSharing = !this.isFileSharing;
  }

  @action
  searchByQuery() {
    clearInterval(this.searchInterval);
    this.searchInterval = setInterval(() => {
      let searchQuery = this.navService.searchQueryInput;
      if (searchQuery && searchQuery.trim(" ").length > 2) {
        this.navService.searchQuery = searchQuery;
        this.router.transitionTo("teams.index", {
          queryParams: {
            q: this.navService.searchQuery,
            team_id: undefined,
            folder_id: undefined
          }
        });
      }
    }, 800);
  }
}
