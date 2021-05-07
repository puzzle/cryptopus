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
  @service inViewport;

  HIDE_TIME = 5;

  passwordHideCountdownTime;

  passwordHideTimerInterval;

  @tracked
  isAccountEditing = false;

  @tracked
  isPasswordVisible = false;

  @tracked
  isUsernameVisible = false;

  @tracked
  isShown = false;

  @action
  copyPassword() {
    let password = this.args.account.cleartextPassword;
    if (isNone(password)) {
      this.fetchAccount().then((a) => {
        this.copyToClipboard(a.cleartextPassword);
        this.onCopied("password");
      });
    } else {
      this.copyToClipboard(password);
      this.onCopied("password");
    }
  }

  @action
  copyUsername() {
    let username = this.args.account.cleartextUsername;
    if (isNone(username)) {
      this.fetchAccount().then((a) => {
        this.copyToClipboard(a.cleartextUsername);
        this.onCopied("username");
      });
    } else {
      this.copyToClipboard(username);
      this.onCopied("username");
    }
  }

  copyToClipboard(text) {
    // Copying to clipboard is not possible in another way. Even libraries do it with a fake element.
    // We don't use the addon ember-cli-clipboard, as we need to wait for a async call to finish.
    const fakeEl = document.createElement("textarea");
    fakeEl.value = text;
    fakeEl.setAttribute("readonly", "");
    fakeEl.style.position = "absolute";
    fakeEl.style.left = "-9999px";
    document.body.appendChild(fakeEl);
    fakeEl.select();
    document.execCommand("copy");
    document.body.removeChild(fakeEl);
  }

  @action
  fetchAccount() {
    return this.store
      .findRecord("account-credential", this.args.account.id, { reload: true })
      .catch((error) => {
        if (error.message.includes("401"))
          window.location.replace("/session/new");
      });
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

    this.passwordHideCountdownTime = new Date().getTime();

    this.passwordHideTimerInterval = setInterval(() => {
      let now = new Date().getTime();

      let passedTime = now - this.passwordHideCountdownTime;

      let passedTimeInSeconds = Math.floor(passedTime / 1000);

      if (passedTimeInSeconds >= this.HIDE_TIME) {
        this.isPasswordVisible = false;
        clearInterval(this.passwordHideTimerInterval);
      }
    }, 1000);
  }

  @action
  setupInViewport(element) {
    const viewportTolerance = { bottom: 200, top: 200 };
    const { onEnter } = this.inViewport.watchElement(element, {
      viewportTolerance
    });
    // pass the bound method to `onEnter` or `onExit`
    onEnter(this.didEnterViewport.bind(this));
  }

  didEnterViewport() {
    this.isShown = true;
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

  willDestroy() {
    // need to manage cache yourself if you don't use the mixin
    const loader = document.getElementById(
      `loader-account-${this.args.account.id}`
    );
    this.inViewport.stopWatching(loader);

    super.willDestroy(...arguments);
  }
}
