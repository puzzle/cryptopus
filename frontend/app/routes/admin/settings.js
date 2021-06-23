import AdminRoute from "../admin";
import { getNames } from "ember-i18n-iso-countries";
import RSVP from "rsvp";
import ENV from "../../config/environment";

export default class AdminSettingsRoute extends AdminRoute {
  model() {
    let locale = "";
    if (ENV.preferredLocale != "ch_be") {
      locale = ENV.preferredLocale;
    } else {
      locale = "de";
    }
    const ISOArray = Object.entries(getNames(locale));
    const countries = ISOArray.map((countryArray) => {
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
