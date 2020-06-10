import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";

export default Helper.extend({
  intl: service(),

  compute(params) {
    return this.intl.t(`${this.translationKeyPrefix()}.${params[0]}`);
  },

  translationKeyPrefix() {
    return this.intl.locale[0].replace("-", "_");
  }
});
