import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";

export default Helper.extend({
  intl: service(),

  compute(params) {
    let [encryptable, attr] = params;
    let isBlank = false;

    if (attr == "password") {
      isBlank = encryptable.isPasswordBlank;
    }
    if (attr == "username") {
      isBlank = encryptable.isUsernameBlank;
    }

    if (isBlank) {
      return this.intl.t(`encryptable/credentials.show.blank`);
    } else {
      if (attr == "password") {
        return encryptable.cleartextPassword;
      }
      if (attr == "username") {
        return encryptable.cleartextUsername;
      }
    }
  }
});
