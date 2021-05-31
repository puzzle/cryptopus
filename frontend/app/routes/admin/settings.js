import AdminRoute from "../admin";
import { getNames } from "ember-i18n-iso-countries";
import RSVP from "rsvp";

export default class AdminSettingsRoute extends AdminRoute {
  model() {
    const ISOArray = Object.entries(getNames("de"));
    const countries = ISOArray.map((countryArray) => {
      return { value: countryArray[0], label: countryArray[1] };
    });
    return RSVP.hash({
      countries: countries,
    });
  }
}
