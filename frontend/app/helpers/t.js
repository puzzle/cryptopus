import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";

export default Helper.extend({
  intl: service(),

  compute(params) {
    if (!params[0]) return;
    return this.intl.t(`${this.getTranslationKeyPrefix()}.${params[0]}`);
  },

  getTranslationKeyPrefix() {
    return this.intl.locale[0].replace("-", "_");
  }
});
