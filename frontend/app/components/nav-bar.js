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
  isNewEncryptable = false;

  @tracked
  isNewFolder = false;

  @tracked
  isNewTeam = false;

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
  toggleEncryptableCreating() {
    this.isNewEncryptable = !this.isNewEncryptable;
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
    clearInterval(this.searchInterval);
    this.searchInterval = setInterval(() => {
      if (
        this.navService.searchQuery &&
        this.navService.searchQuery.trim(" ").length > 2
      ) {
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
