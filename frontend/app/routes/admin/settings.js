import AdminRoute from "../admin";
import RSVP from "rsvp";
import ENV from "../../config/environment";
import * as countries from "i18n-iso-countries";
import en from "i18n-iso-countries/langs/en.json";

export default class AdminSettingsRoute extends AdminRoute {
  ISOArray = [];
  constructor() {
    super(...arguments);
    countries.registerLocale(en);
    let locale = ENV.preferredLocale !== "ch_be" ? ENV.preferredLocale : "de";
    this.ISOArray = Object.entries(countries.getNames(locale));
  }
  model() {
    const countries = this.ISOArray.map((countryArray) => {
      return { value: countryArray[0], label: countryArray[1] };
    });

    const ipAddresses = [];
    return RSVP.hash({
      countries: countries,
      ipAddresses: ipAddresses,
      isGeoIPenabled: ENV.geoIP
    });
  }
}
