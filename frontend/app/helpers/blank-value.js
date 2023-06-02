import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";
import { capitalize } from "@ember/string";

export default Helper.extend({
  intl: service(),

  compute(params) {
    let [encryptable, attr] = params;
    let isBlank = false;

    isBlank = encryptable[`is${capitalize(attr)}Blank`];

    return isBlank;
  }
});
