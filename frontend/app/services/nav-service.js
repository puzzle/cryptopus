import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class NavService extends Service {
  @tracked selectedTeam = null;
  @tracked selectedFolder = null;
  @tracked searchQuery = null;
  @tracked searchQueryInput = null;

  @tracked isShowingFavourites;
  @tracked isLoadingTeams = true;
  @tracked availableTeams = [];

  @service store;
  @service router;

  constructor() {
    super(...arguments);

    this.fetchTeams();
  }

  get showSideNavBar() {
    const sideNavBarDisabledRoutes = [
      "admin.settings",
      "admin.users",
      "profile"
    ];
    return !sideNavBarDisabledRoutes.includes(this.router.currentRouteName);
  }

  fetchTeams() {
    let favourites = localStorage.getItem("showsFavourites") === "true";
    this.isShowingFavourites = favourites;
    this.store
      .query("team", {
        favourite: this.isShowingFavourites
          ? this.isShowingFavourites
          : undefined
      })
      .then((res) => {
        this.availableTeams = this._sortTeams(res);
        this.isLoadingTeams = false;
      });
  }

  _sortTeams(teams) {
    return teams.toArray().sort((a, b) => {
      if (a.isPersonalTeam) {
        return -1;
      }
      if (b.isPersonalTeam) {
        return 1;
      }
      return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
    });
  }

  clear() {
    this.clearNavSelection();
    this.clearSearch();
  }

  clearSearch() {
    this.searchQueryInput = null;
    this.searchQuery = null;
  }

  clearNavSelection() {
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

  get isOnDashboardRoute() {
    const DASHBOARD_ROUTE = "dashboard";
    return this.router.currentRouteName === DASHBOARD_ROUTE;
  }
}
