import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class NavBarComponent extends Component {
  @tracked
  isNewAccount = false;

  @tracked
  isNewFolder = false;

  @tracked
  isNewTeam = false;

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
