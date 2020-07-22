import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import ENV from "../config/environment";

export default class IndexRoute extends Route {
  @service notify;
  @service intl;
  @service store;

  beforeModel() {
    let selectedLocale = this.intl.locales.includes(ENV.preferredLocale.replace("_", "-"))
      ? ENV.preferredLocale
      : "en";

    this.intl.setLocale(selectedLocale);
  }

  @action
  error(error) {
    if (error.message.includes("403") || error.message.includes("404")) {
      let prefix = this.intl.locale[0].replace("-", "_");
      let msg = this.intl.t(`${prefix}.${error.errors[0]}`);
      this.notify.error(msg);
      this.replaceWith("index");
    } else if (error.message.includes("401")) {
      window.location.replace("/session/new");
    }
  }
}
