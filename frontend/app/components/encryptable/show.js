import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class ShowComponent extends Component {
  @service router;

  constructor() {
    super(...arguments);

    window.scrollTo(0, 0);
  }

  @tracked
  isEncryptableEditing = false;

  @tracked
  isFileCreating = false;

  @tracked
  isFile = this.args.encryptable.isFile;

  @tracked
  isCredentialSharing = false;

  @tracked isTransferredCredentials =
    this.args.encryptable.sender_name !== null;

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
  }

  @action
  toggleFileNew() {
    this.isFileCreating = !this.isFileCreating;
  }

  get downloadLink() {
    return `/api/encryptables/${this.args.encryptable.get("id")}`;
  }

  @action
  refreshRoute() {
    this.router.transitionTo("/teams");
  }

  @action
  toggleCredentialSharing() {
    this.isCredentialSharing = !this.isCredentialSharing;
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
