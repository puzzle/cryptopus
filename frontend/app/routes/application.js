import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import ENV from "../config/environment";

export default class IndexRoute extends Route {
  @service notify;
  @service intl;

  async beforeModel() {
    if(ENV.environment !== "test") {
      const response = await fetch("/api/env_settings");
      const envSettings = await response.json();
      this.setEnvs(envSettings);
    }
    let selectedLocale = this.intl.locales.includes(
      ENV.preferredLocale.replace("_", "-")
    )
      ? ENV.preferredLocale
      : "en";

    this.intl.setLocale(selectedLocale);
  }

  setEnvs(envSettings) {
    ENV.sentryDsn = envSettings.sentry;
    ENV.currentUserId = envSettings.current_user.id;
    ENV.currentUserRole = envSettings.current_user.role;
    ENV.currentUserGivenname = envSettings.current_user.givenname;
    ENV.currentUserUsername = envSettings.current_user.username;
    ENV.currentUserLastLoginAt = envSettings.current_user.last_login_at;
    ENV.currentUserLastLoginFrom = envSettings.current_user.last_login_from;
    ENV.currentUserAuth = envSettings.current_user.auth;
    ENV.currentUserDefaultCcliUserId =
      envSettings.current_user.default_ccli_user_id;
    ENV.preferredLocale = envSettings.current_user.preferred_locale;
    ENV.lastLoginMessage = envSettings.last_login_message;
    ENV.geoIP = envSettings.geo_ip;
    ENV.appVersion = envSettings.version;
    ENV.CSRFToken = envSettings.csrf_token;
    ENV.authProvider = envSettings.auth_provider;
    ENV.fallbackInfo = envSettings.fallback_info;
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
