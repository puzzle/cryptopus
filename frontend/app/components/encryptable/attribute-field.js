import Component from "@glimmer/component";
import { action } from "@ember/object";
import {tracked} from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class AttributeField extends Component {

  @service notify;
  @service intl;
  @service store;

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

  startHideAttributeTimer(attribute) {
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
  onCopied(attribute) {
    this.notify.info(this.intl.t(`flashes.encryptables.${attribute}_copied`));
  }

  get noCopyBlankTooltip() {
    return this.intl.t("encryptable/credentials.show.blank");
  }
}

