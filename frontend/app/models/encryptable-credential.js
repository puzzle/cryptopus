import Encryptable from "./encryptable";
import { attr, hasMany } from "@ember-data/model";
import { isNone } from "@ember/utils";

export default class EncryptableCredential extends Encryptable {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @hasMany("encryptable-file") encryptableFiles;

  get isPasswordBlank() {
    return this.isFullyLoaded && isNone(this.cleartextPassword);
  }

  get isUsernameBlank() {
    return this.isFullyLoaded && isNone(this.cleartextUsername);
  }
}
