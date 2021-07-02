import IntlService from "ember-intl/services/intl";

export default class Intl extends IntlService {
  t(translationKey) {
    let translationKeyPrefix = this.locale[0].replace("-", "_");
    return super.t(`${translationKeyPrefix}.${translationKey}`);
  }
}
