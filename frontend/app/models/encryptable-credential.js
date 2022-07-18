import Encryptable from "./encryptable";
import { attr, hasMany } from "@ember-data/model";
import { isNone } from "@ember/utils";

export default class EncryptableCredential extends Encryptable {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @hasMany("encryptable-file") encryptableFiles;

  get isFullyLoaded() {
    return (
      !this.id ||
      this.cleartextUsername !== undefined ||
      this.cleartextPassword !== undefined
    );
  }

  get isPasswordBlank() {
    return isNone(this.cleartextPassword);
  }

  get isUsernameBlank() {
    return isNone(this.cleartextUsername);
  }
}
