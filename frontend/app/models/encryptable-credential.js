import Encryptable from "./encryptable";
import { attr, hasMany } from "@ember-data/model";
import { isNone } from "@ember/utils";

export default class EncryptableCredential extends Encryptable {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") cleartextToken;
  @attr("string") cleartextPin;
  @attr("string") cleartextEmail;
  @hasMany("encryptable-file") encryptableFiles;
  @attr({defaultValue: null}) cleartextCustomAttr;

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
}
