import Helper from "@ember/component/helper";
import { capitalize } from "@ember/string";
import { inject as service } from "@ember/service";

export default Helper.extend({
  intl: service(),

  compute(params) {
    let [encryptable, attr] = params;
    const attrName = capitalize(attr);
    const isBlank = eval(`encryptable.is${attrName}Blank`);
    if (isBlank) {
      return this.intl.t(`encryptable/credentials.show.blank`);
    } else {
      return eval(`encryptable.cleartext${attrName}`);
    }
  }
});
