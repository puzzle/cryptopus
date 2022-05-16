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
  @service clipboardService;
  @service notify;
  @service intl;
  @service fetchService;

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

  @action
  copyCcliLogin() {
    this.fetchService
      .send(`/api/api_users/${ENV.currentUserId}/ccli_token`, { method: "GET" })
      .then((response) => {
        response.json().then((json) => {
          this.clipboardService.copy(
            `cry login ${btoa(`${json.username}:${json.token}`)}@${
              window.location.origin
            }`
          );
          this.notify.success(
            this.intl.t("flashes.api.api-users.ccli_login.copied")
          );
        });
      });
  }
}
