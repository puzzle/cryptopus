import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default class IndexRoute extends Route {
  @service intl;
  @service store;

  model() {
    return this.store.findAll("team");
  }

  beforeModel() {
    /* eslint-disable no-undef */
    let localeDropdown = $(".container form option[selected='selected']");
    /* eslint-enable no-undef */
    let selectedLocale = (localeDropdown[0] && localeDropdown[0].value) || "en";
    this.intl.setLocale(selectedLocale);
  }
}
