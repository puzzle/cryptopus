import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import ENV from "../config/environment";
import { tracked } from "@glimmer/tracking";

export default class FooterComponent extends Component {
  @service intl;
  @service fetchService;
  @service logoutTimerService;

  @tracked
  isChangelogOpen = false;

  availableLocales = [
    { key: "en", name: "English" },
    { key: "de", name: "Deutsch" },
    { key: "fr", name: "Français" },
    { key: "ch-be", name: "Bärndütsch" }
  ];

  @action
  toggleChangelogModal() {
    this.isChangelogOpen = !this.isChangelogOpen;
  }

  get version() {
    return ENV.appVersion;
  }

  get selectedLocale() {
    let primaryLocale = this.intl.primaryLocale;
    return this.availableLocales.find((locale) => locale.key === primaryLocale);
  }

  @action
  setLocale(locale) {
    let data = {
      data: { attributes: { preferred_locale: locale.key.replace("-", "_") } }
    };

    this.intl.setLocale(locale.key);
    this.fetchService.send(`/api/profile`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": ENV.CSRFToken
      },
      body: JSON.stringify(data)
    });
  }
}
