import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import ENV from "../config/environment";

export default class TeamShowComponent extends Component {
  @service navService;
  @service userService;
  @service store;
  @service router;

  @tracked
  isTeamEditing = false;

  @tracked
  isTeamConfiguring = false;

  @tracked
  isNewFolder = false;

  @tracked
  collapsed =
    this.navService.selectedTeam != this.args.team &&
    this.navService.searchQuery === null;

  @action
  collapse() {
    this.collapsed = !this.collapsed;
  }
  @action
  toggleTeamEdit() {
    this.isTeamEditing = !this.isTeamEditing;
  }

  @action
  toggleTeamConfigure() {
    this.isTeamConfiguring = !this.isTeamConfiguring;
  }

  @action
  toggleFolderCreating() {
    this.isNewFolder = !this.isNewFolder;
  }

  @action
  transitionToIndex() {
    this.navService.availableTeams.removeObject(this.args.team);
    this.router.transitionTo("index");
  }

  @action
  toggleFavourised() {
    let httpMethod = this.args.team.favourised ? "delete" : "post";
    /* eslint-disable no-undef  */
    fetch(`/api/teams/${this.args.team.id}/favourite`, {
      method: httpMethod,
      headers: {
        "X-CSRF-Token": ENV.CSRFToken
      }
    }).then(() => {
      this.args.team.favourised = !this.args.team.favourised;
      if (this.navService.isShowingFavourites) {
        if (this.args.team.favourised) {
          this.navService.availableTeams.pushObject(this.args.team);
        } else {
          this.navService.availableTeams.removeObject(this.args.team);
        }
      }
    });
    /* eslint-enable no-undef  */
  }
}
