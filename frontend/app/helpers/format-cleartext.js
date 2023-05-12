import Helper from "@ember/component/helper";
import { inject as service } from "@ember/service";

export default Helper.extend({
  intl: service(),

  compute(params) {
    let [encryptable, attr] = params;
    let isBlank = false;

    if (attr === "password") {
      isBlank = encryptable.isPasswordBlank;
    }
    if (attr === "username") {
      isBlank = encryptable.isUsernameBlank;
    }
    if (attr === "pin") {
      isBlank = encryptable.isPinBlank;
    }
    if (attr === "token") {
      isBlank = encryptable.isTokenBlank;
    }
    if (attr === "email") {
      isBlank = encryptable.isEmailBlank;
    }
    if (attr === "customAttr") {
      isBlank = encryptable.isCustomAttrBlank;
    }

    if (isBlank) {
      return this.intl.t(`encryptable/credentials.show.blank`);
    } else {
      if (attr === "password") {
        return encryptable.cleartextPassword;
      }
      if (attr === "username") {
        return encryptable.cleartextUsername;
      }
      if (attr === "pin") {
        return encryptable.cleartextPin;
      }
      if (attr === "token") {
        return encryptable.cleartextToken;
      }
      if (attr === "email") {
        return encryptable.cleartextEmail;
      }
      if (attr === "customAttr") {
        //make it null save because custom attr is nested
        return (
          encryptable.cleartextCustomAttr == null
            ? ""
            : encryptable.cleartextCustomAttr
        ).value;
      }
    }
  }
});
