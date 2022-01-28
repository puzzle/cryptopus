import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class ShowComponent extends Component {
  @service store;
  @service router;

  constructor() {
    super(...arguments);

    window.scrollTo(0, 0);
  }

  @tracked
  isEncryptableEditing = false;

  @tracked
  isPasswordVisible = false;

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
  }

  @action
  showPassword() {
    this.isPasswordVisible = true;
  }

  @action
  refreshRoute() {
    this.router.transitionTo("/teams");
  }

  @action
  transitionBack() {
    this.router.transitionTo(
      "teams.folders-show",
      this.args.encryptable.folder.get("team.id"),
      this.args.encryptable.folder.get("id")
    );
  }
}
