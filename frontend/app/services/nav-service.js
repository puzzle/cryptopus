import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class NavService extends Service {
  @tracked selectedTeam = null;
  @tracked selectedFolder = null;
  @tracked searchQuery = null;

  @tracked isShowingFavourites;
  @tracked isLoadingTeams = true;
  @tracked availableTeams = [];

  @service store;
  @service router;

  get sortedTeams() {
    return this.availableTeams.toArray().sort((a, b) => {
      return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
    });
  }

  get showSideNavBar() {
    const sideNavBarDisabledRoutes = [
      "admin.settings",
      "admin.users",
      "profile",
      "personal_logs"
    ];
    return !sideNavBarDisabledRoutes.includes(this.router.currentRouteName);
  }

  clear() {
    this.selectedTeam = null;
    this.selectedFolder = null;
    this.searchQuery = null;
  }

  setSelectedTeamById(team_id) {
    this.selectedTeam = team_id ? this.store.peekRecord("team", team_id) : null;
  }

  setSelectedFolderById(folder_id) {
    this.selectedFolder = folder_id
      ? this.store.peekRecord("folder", folder_id)
      : null;
  }

  get isOnDashboardRoute() {
    const DASHBOARD_ROUTE = "dashboard";
    return this.router.currentRouteName === DASHBOARD_ROUTE;
  }
}
