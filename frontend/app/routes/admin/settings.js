import Route from '@ember/routing/route';
import { getNames } from 'ember-i18n-iso-countries';

export default class Settings extends Route {
    async model() {
      const countriesArray = [];
      const ISOArray = Object.entries(getNames("de"));
      for (const country of ISOArray) {
        countriesArray.push(country[1]);
      }
      return {
        countryCodes: countriesArray,
    }
  }
}