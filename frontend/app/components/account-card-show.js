import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class AccountCardShowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  @tracked isPreview = true;

  @tracked
  isAccountEditing = false;

  @tracked
  isPasswordVisible = false;

  @action
  swapToCredentialsView() {
    this.isPreview = false;
    this.store.findRecord("account", this.args.account.id);
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
  toggleAccountEdit() {
    this.isAccountEditing = !this.isAccountEditing;
  }

  @action
  showPassword() {
    this.isPasswordVisible = true;
  }

  @action
  onCopied(attribute) {
    let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
    let msg = this.intl.t(
      `${translationKeyPrefix}.flashes.accounts.${attribute}_copied`
    );
    this.notify.info(msg);
  }
}
