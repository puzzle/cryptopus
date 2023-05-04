import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class ShowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

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

  @tracked
  isPinVisible = false;

  @tracked
  isTokenVisible = false;

  @tracked
  isEmailVisible = false;

  @tracked
  isCustomAttrVisible = false;

  @tracked
  isFile = this.args.encryptable.isFile;

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
  showValue(value) {
    if (value === "password") {
      this.isPasswordVisible = true;
    } else if (value === "pin") {
      this.isPinVisible = true;
    } else if (value === "token") {
      this.isTokenVisible = true;
    } else if (value === "email") {
      this.isEmailVisible = true;
    } else if (value === "customAttr") {
      this.isCustomAttrVisible = true;
    }
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

  get noCopyBlankTooltip() {
    return this.intl.t("encryptable/credentials.show.blank");
  }
}
