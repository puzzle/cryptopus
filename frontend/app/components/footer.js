import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import fetch from "fetch";
import ENV from "../config/environment";

export default class FooterComponent extends Component {
  @service intl;

  availableLocales = [
    { key: "en", name: "English" },
    { key: "de", name: "Deutsch" },
    { key: "fr", name: "Français" },
    { key: "ch-be", name: "Bärndütsch" }
  ];

  get version() {
    return ENV.appVersion;
  }

  get selectedLocale() {
    let primaryLocale = this.intl.primaryLocale;
    return this.availableLocales.find(locale => locale.key === primaryLocale);
  }

  @action
  setLocale(locale) {
    let data = {
      data: { attributes: { preferred_locale: locale.key.replace("-", "_") } }
    };

    /* eslint-disable no-undef  */
    this.intl.setLocale(locale.key);
    fetch(`/api/locale`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
      },
      body: JSON.stringify(data)
    });
    /* eslint-enable no-undef  */
  }
}
