import Encryptable from "./encryptable";
import { attr, hasMany } from "@ember-data/model";
import { isNone } from "@ember/utils";

export default class EncryptableCredential extends Encryptable {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") cleartextToken;
  @attr("string") cleartextPin;
  @attr("string") cleartextEmail;
  @attr("string") cleartextCustomAttr;
  @attr("string") cleartextCustomAttrLabel;
  @attr() usedEncryptedDataAttrs;
  @hasMany("encryptable-file") encryptableFiles;

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
    return this.isFullyLoaded && isNone(this.cleartextCustomAttr);
  }
}
