import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import ENV from "../config/environment";

export default class ApplicationRoute extends Route {
  @service notify;
  @service intl;
  @service logoutTimerService;
  @service store;
  @service envSettingsService;

  async beforeModel() {
    await this.envSettingsService.applyEnvSettings();
    let selectedLocale = this.intl.locales.includes(
      ENV.preferredLocale.replace("_", "-")
    )
      ? ENV.preferredLocale
      : "en";

    this.intl.setLocale(selectedLocale);
  }

  @action
  error(error) {
    if (error.message.includes("403") || error.message.includes("404")) {
      this.notify.error(this.getErrorMessage(error));
      this.replaceWith("index");
    } else if (error.message.includes("401")) {
      window.location.replace("/session/new");
    }
  }

  @action
  didTransition() {
    this.logoutTimerService.start();
    return true; // Bubble the didTransition event
  }

  getErrorMessage(error) {
    let msg = this.intl.t("something_went_wrong");
    let error_msg = error?.errors[0];

    if (typeof error_msg === "string") {
      msg = this.intl.t(error.errors[0]);
    } else if (typeof error_msg === "object" && error_msg != null) {
      switch (error_msg.status) {
        case "403":
          msg = this.intl.t("flashes.admin.admin.no_access");
          break;
        case "404":
          msg = this.intl.t("flashes.api.errors.record_not_found");
          break;
      }
    }

    return msg;
  }
}
