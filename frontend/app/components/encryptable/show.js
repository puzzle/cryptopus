import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import RSVP from "rsvp";
import { computed } from '@ember/object';


export default class ShowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;
  @service navService;

  constructor() {
    super(...arguments);

    window.scrollTo(0, 0);
  }

  @tracked
  isEncryptableEditing = false;

  @tracked
  isFileCreating = false;

  @tracked
  isPasswordVisible = false;

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
  }

  @action
  toggleFileNew() {
    this.isFileCreating = !this.isFileCreating;
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

  @action
  onCopied(attribute) {
    this.notify.info(this.intl.t(`flashes.encryptables.${attribute}_copied`));
  }

  get teamData() {
    debugger
    const folder = this.args.encryptable.belongsTo('folder').value();
    const team = folder.belongsTo('team').value();
    return {
      encryptionAlgorithm: team.encryptionAlgorithm,
      passwordBitsize: team.passwordBitsize,
    }
  }
}
