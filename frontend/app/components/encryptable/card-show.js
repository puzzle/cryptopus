import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class CardShowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  @tracked isPreview = true;

  @tracked
  isEncryptableEditing = false;

  @tracked
  isPasswordVisible = false;

  @action
  swapToCredentialsView() {
    this.isPreview = false;
    this.store.findRecord("encryptable", this.args.encryptable.id);
    this.isPasswordVisible = false;
  }

  @action
  swapToPreview() {
    this.isPreview = true;
  }

  @action
  refreshRoute() {
    this.router.transitionTo();
  }

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
  }

  @action
  showPassword() {
    this.isPasswordVisible = true;
  }

  @action
  onCopied(attribute) {
    this.notify.info(this.intl.t(`flashes.encryptables.${attribute}_copied`));
  }
}
