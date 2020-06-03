import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default class IndexRoute extends Route {
  @service intl;

  beforeModel() {
    /* eslint-disable no-undef */
    let selectedLocale =
      $(".container form option[selected='selected']")[0].value || "en";
    /* eslint-enable no-undef */
    this.intl.setLocale(selectedLocale);
  }
}
