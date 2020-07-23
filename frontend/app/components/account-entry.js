import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class AccountEntryComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  HIDE_TIME = 5;
  hideTimer;

  @tracked
  isAccountEditing = false;

  @tracked
  isPasswordVisible = false;

  @tracked
  isUsernameVisible = false;

  constructor() {
    (super(...arguments));

    /* eslint-disable no-undef  */
    this.hideTimer = new Timer();
    /* eslint-enable no-undef  */

    this.hideTimer.addEventListener('secondsUpdated', () => {
      let passedTime = this.hideTimer.getTotalTimeValues().seconds
      if (passedTime === this.HIDE_TIME) {
        this.isPasswordVisible = false;
        this.hideTimer.stop();
      }
    })
  }

  @action
  fetchAccount() {
    this.store.findRecord("account", this.args.account.id);
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
    this.fetchAccount();
    this.isPasswordVisible = true;
    this.hideTimer.start()
  }

  @action
  showUsername() {
    this.fetchAccount();
    this.isUsernameVisible = true;
  }

  @action
  transitionToAccount() {
    this.router.transitionTo("accounts.show", this.args.account.id);
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
