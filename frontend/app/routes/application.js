import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";

export default class IndexRoute extends Route {
  @service notify;
  @service intl;
  @service store;

  beforeModel() {
    /* eslint-disable no-undef */
    let localeDropdown = $(".container form option[selected='selected']");
    /* eslint-enable no-undef */
    let selectedLocale = (localeDropdown[0] && localeDropdown[0].value) || "en";
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
