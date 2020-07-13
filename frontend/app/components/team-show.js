import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class TeamShowComponent extends Component {
  @service navService;
  @service store;

  @tracked
  isTeamEditing = false;

  @tracked
  isTeamConfiguring = false;

  @tracked
  collapsed = this.navService.selectedTeam != this.args.team;

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
  toggleFavourised() {
    let httpMethod = this.args.team.favourised ? "delete" : "post";
    /* eslint-disable no-undef  */
    fetch(`/api/teams/${this.args.team.id}/favourite`, {
      method: httpMethod,
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
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
