import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class TeamShowComponent extends Component {
  @tracked
  isTeamEditing = false;

  @tracked
  isTeamConfiguring = false;

  @tracked
  collapsed = true;

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
