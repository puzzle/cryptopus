import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isNone } from "@ember/utils";


export default class AccountRowComponent extends Component {
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
  copyPassword() {
    let password = this.args.account.cleartextPassword;
    if(isNone(password)) {
      this.fetchAccount().then(a => {
        this.copyToClipboard(a.cleartextPassword)
        this.onCopied('password');
      })
    } else {
      this.copyToClipboard(password)
      this.onCopied('password');
    }
  }

  @action
  copyUsername() {
    let username = this.args.account.cleartextUsername;
    if(isNone(username)) {
      this.fetchAccount().then(a => {
        this.copyToClipboard(a.cleartextUsername)
        this.onCopied('username');
      })
    } else {
      this.copyToClipboard(username)
      this.onCopied('username');
    }
  }

  copyToClipboard(text) {
    // Copying to clipboard is not possible in another way. Even libraries do it with a fake element.
    // We don't use the addon ember-cli-clipboard, as we need to wait for a async call to finish.
    const fakeEl = document.createElement('textarea');
    fakeEl.value = text
    fakeEl.setAttribute('readonly', '');
    fakeEl.style.position = 'absolute';
    fakeEl.style.left = '-9999px';
    document.body.appendChild(fakeEl);
    fakeEl.select();
    document.execCommand('copy');
    document.body.removeChild(fakeEl);
  }


  @action
  fetchAccount() {
    return this.store.findRecord("account", this.args.account.id, { reload: true });
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
