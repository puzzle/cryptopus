import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isPresent } from "@ember/utils";
import { capitalize } from "@ember/string";

export default class RowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;
  @service inViewport;
  @service clipboardService;

  HIDE_TIME = 5;

  hideCountdownTime;

  hideTimerInterval;

  @tracked
  isEncryptableEditing = false;

  @tracked
  isUsernameVisible = false;

  @tracked
  isPasswordVisible = false;

  @tracked
  isTokenVisible = false;

  @tracked
  isPinVisible = false;

  @tracked
  isEmailVisible = false;

  @tracked
  isCustomAttrVisible = false;

  @tracked
  isShown = false;

  @tracked
  isFile = this.args.encryptable.isFile;

  constructor() {
    super(...arguments);
  }

  // get set attribute amount to hide attribute fields in encryptable row when encryptable has more than two attributes
  get getAttributesAmount() {
    return Object.values(this.args.encryptable.usedAttrs).filter(Boolean)
      .length;
  }

  @action
  copyAttribute(attribute) {
    this.fetchAndCopyToClipboard(attribute);
  }

  fetchAndCopyToClipboard(attr) {
    const encryptable = this.args.encryptable;
    if (encryptable.isFullyLoaded) {
      const value = encryptable[`cleartext${capitalize(attr)}`];
      this.copyToClipboard(attr, value);
    } else {
      this.fetchEncryptable().then((a) => {
        const value = a[`cleartext${capitalize(attr)}`];
        this.copyToClipboard(attr, value);
      });
    }
  }

  copyToClipboard(attr, value) {
    if (isPresent(value)) {
      this.clipboardService.copy(value);
      this.notifyCopied(attr);
    }
  }

  notifyCopied(attr) {
    this.notify.info(this.intl.t(`flashes.encryptables.${attr}_copied`));
  }

  fetchEncryptable() {
    return this.store
      .findRecord("encryptable-credential", this.args.encryptable.id, {
        reload: true
      })
      .catch((error) => {
        if (error.message.includes("401"))
          window.location.replace("/session/new");
      });
  }

  formattedValue(encryptable, attr) {
    let value = "";
    if (encryptable.isPasswordBlank) {
      value = this.intl.t(`encryptable/credential.${attr}_blank`);
    }

    return value;
  }

  @action
  refreshRoute() {
    this.router.transitionTo();
  }

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
  }

  get downloadLink() {
    return `/api/encryptables/${this.args.encryptable.get("id")}`;
  }

  @action
  showAttribute(attribute) {
    this.fetchEncryptable();
    this[`is${capitalize(attribute)}Visible`] = true;

    this.startHideAttributeTimer(attribute);
  }

  startHideAttributeTimer(attribute) {
    this.hideCountdownTime = new Date().getTime();

    this.hideTimerInterval = setInterval(() => {
      let now = new Date().getTime();

      let passedTime = now - this.hideCountdownTime;

      let passedTimeInSeconds = Math.floor(passedTime / 1000);

      if (passedTimeInSeconds >= this.HIDE_TIME) {
        this[`is${capitalize(attribute)}Visible`] = false;
        clearInterval(this.hideTimerInterval);
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
