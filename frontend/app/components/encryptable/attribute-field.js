import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { capitalize } from "@ember/string";
import { isPresent } from '@ember/utils';

export default class AttributeField extends Component {
  @service notify;
  @service intl;
  @service store;
  @service clipboardService;

  @tracked
  isAttributeVisible = this.args.visibleByDefault;

  HIDE_TIME = 5;

  hideCountdownTime;

  hideTimerInterval;

  constructor() {
    super(...arguments);
  }

  @action
  showValue() {
    if (this.args.row) {
      this.fetchEncryptable();
      this.startHideAttributeTimer();
    }

    this.isAttributeVisible = true;
  }

  startHideAttributeTimer() {
    this.hideCountdownTime = new Date().getTime();

    this.hideTimerInterval = setInterval(() => {
      let now = new Date().getTime();

      let passedTime = now - this.hideCountdownTime;

      let passedTimeInSeconds = Math.floor(passedTime / 1000);

      if (passedTimeInSeconds >= this.HIDE_TIME) {
        this.isAttributeVisible = false;
        clearInterval(this.hideTimerInterval);
      }
    }, 1000);
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

  @action
  copyAttribute() {
    if (this.args.row) {
      this.fetchAndCopyToClipboard();
    } else {
      this.copyToClipboard(this.args.encryptable[`cleartext${capitalize(this.args.attribute)}`]);
    }
  }

  fetchAndCopyToClipboard() {
    const encryptable = this.args.encryptable;
    if (encryptable[`cleartext${capitalize(this.args.attribute)}`]) {
      this.copyToClipboard(encryptable[`cleartext${capitalize(this.args.attribute)}`]);
    } else {
      this.fetchEncryptable().then((a) => {
        this.copyToClipboard(a[`cleartext${capitalize(this.args.attribute)}`]);
      });
    }
  }

  copyToClipboard(value) {
    this.clipboardService.copy(value);
    this.notify.info(this.intl.t(`flashes.encryptables.${this.args.attribute}_copied`));
  }

  get noCopyBlankTooltip() {
    return this.intl.t("encryptable/credentials.show.blank");
  }
}
