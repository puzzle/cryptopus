import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";
import { capitalize } from "@ember/string";

export default Helper.extend({
  intl: service(),

  compute(params) {
    let [encryptable, attr] = params;
    let isBlank = false;

    isBlank = encryptable[`is${capitalize(attr)}Blank`];

    if (isBlank) {
      return this.intl.t(`encryptable/credentials.show.blank`);
    } else {
      if (attr === "customAttr") {
        //make it null save because custom attr is nested
        return (
          encryptable.cleartextCustomAttr == null
            ? ""
            : encryptable.cleartextCustomAttr
        ).value;
      }
      return encryptable[`cleartext${capitalize(attr)}`];
    }
  }
});
