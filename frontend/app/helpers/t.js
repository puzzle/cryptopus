import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";

export default Helper.extend({
  intl: service(),

  compute(params) {
    // We're still overriding the t helper from intl, since the intl t helper is not able to handle null as an argument
    // Yet we need this functionality, especially with our form validations
    if (!params[0]) return;
    return this.intl.t(params[0]);
  }
});
