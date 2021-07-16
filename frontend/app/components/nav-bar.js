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


  searchInterval;

  @tracked
  isNewAccount = false;

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

  @action
  copyCcliLogin(apiUser) {
    this.fetchService
      .send(`/api/api_users/${apiUser.id}/token`, { method: "GET" })
      .then((response) => {
        response.json().then((json) => {
          this.clipboardService.copy(
            `cry login ${btoa(`${json.token}:${json.username}`)}@${
              window.location.origin
            }`
          );
          let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
          let successMsg = `${translationKeyPrefix}.flashes.api.api-users.ccli_login.copied`;
          let msg = this.intl.t(successMsg);
          this.notify.success(msg);
        });
      });
  }
}
