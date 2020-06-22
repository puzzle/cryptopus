import Component from "@ember/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class TeamShowComponent extends Component {
  @service navService;

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
}
