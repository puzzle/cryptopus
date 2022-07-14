import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isNone, isPresent } from "@ember/utils";
import { capitalize } from "@ember/string";

export default class RowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;
  @service inViewport;
  @service clipboardService;

  HIDE_TIME = 5;

  passwordHideCountdownTime;

  passwordHideTimerInterval;

  @tracked
  isEncryptableEditing = false;

  @tracked
  isPasswordVisible = false;

  @tracked
  isUsernameVisible = false;

  @tracked
  isShown = false;

  @action
  copyPassword() {
    this.fetchAndCopyToClipboard("password");
  }

  @action
  copyUsername() {
    this.fetchAndCopyToClipboard("username");
  }

  fetchAndCopyToClipboard(attr) {
    const encryptable = this.args.encryptable;
    let value = eval(`encryptable.cleartext${capitalize(attr)}`);
    if (encryptable.isFullyLoaded) {
      this.copyToClipboard(attr, value);
    } else {
      this.fetchAccount().then((a) => {
        value = eval(`a.cleartext${capitalize(attr)}`);
        this.copyToClipboard(attr, value);
      });
    }
  }

  copyToClipboard(attr, value) {
    if (isPresent(value)) {
      this.clipboardService.copy(value);
      this.notifyCopied(attr);
    } else {
      this.notifyCopied("empty");
    }
  }

  notifyCopied(attr) {
    this.notify.info(this.intl.t(`flashes.encryptables.${attr}_copied`));
  }

  fetchAccount() {
    return this.store
      .findRecord("encryptable-credential", this.args.encryptable.id)
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
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
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
    this.router.transitionTo("encryptables.show", this.args.encryptable.id);
  }

  willDestroy() {
    // need to manage cache yourself if you don't use the mixin
    const loader = document.getElementById(
      `loader-encryptable-${this.args.encryptable.id}`
    );
    this.inViewport.stopWatching(loader);

    super.willDestroy(...arguments);
  }
}
