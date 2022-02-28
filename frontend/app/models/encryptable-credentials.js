import Encryptable from "./encryptable";
import { attr, hasMany } from "@ember-data/model";

export default class EncryptableCredentials extends Encryptable {
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
}
