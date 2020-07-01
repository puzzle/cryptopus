import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class NavBarComponent extends Component {
  @service router;

  @tracked
  isNewAccount = false;

  @tracked
  isNewFolder = false;

  @tracked
  isNewTeam = false;

  get isStartpage() {
    return this.router.currentRouteName === "index";
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
}
