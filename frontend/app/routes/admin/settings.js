import AdminRoute from "../admin";
import { getNames } from 'ember-i18n-iso-countries';

export default class AdminSettingsRoute extends AdminRoute {
  model() {
    const countriesArray = [];
    const ISOArray = Object.entries(getNames("de"));
    ISOArray.forEach(arr => {
        countriesArray.push(arr[1])
    });
    return {
      countryCodes: countriesArray,
  }
  }
}