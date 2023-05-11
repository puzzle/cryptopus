import Encryptable from "./encryptable";
import { attr, hasMany } from "@ember-data/model";
import { isNone } from "@ember/utils";

export default class EncryptableCredential extends Encryptable {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") cleartextToken;
  @attr("string") cleartextPin;
  @attr("string") cleartextEmail;
  @attr({defaultValue: undefined}) cleartextCustomAttr;
  @attr() usedAttrs;
  @hasMany("encryptable-file") encryptableFiles;

  get value() {
    return this.cleartextCustomAttr?.value;
  }

  set value(value) {
    this.cleartextCustomAttr = this.cleartextCustomAttr || {};
    this.cleartextCustomAttr.value = value;
  }

  get label() {
    return this.cleartextCustomAttr?.label;
  }

  set label(value) {
    this.cleartextCustomAttr = this.cleartextCustomAttr || {};
    this.cleartextCustomAttr.label = value;
  }

  get isPasswordBlank() {
    return this.isFullyLoaded && isNone(this.cleartextPassword);
  }

  get isUsernameBlank() {
    return this.isFullyLoaded && isNone(this.cleartextUsername);
  }

  get isTokenBlank() {
    return this.isFullyLoaded && isNone(this.cleartextToken);
  }

  get isPinBlank() {
    return this.isFullyLoaded && isNone(this.cleartextPin);
  }

  get isEmailBlank() {
    return this.isFullyLoaded && isNone(this.cleartextEmail);
  }

  get isCustomAttrBlank() {
    //make it null save because custom attr is nested
    return this.isFullyLoaded && isNone((this.cleartextCustomAttr == null ? "" : this.cleartextCustomAttr).value);
  }
}
