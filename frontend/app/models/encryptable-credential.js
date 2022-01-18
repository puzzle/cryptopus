import Encryptable from "./encryptable";
import { attr } from "@ember-data/model";

export default class EncryptableCredential extends Encryptable {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;

  get isFullyLoaded() {
    return (
      !this.id ||
      this.cleartextUsername !== undefined ||
      this.cleartextPassword !== undefined
    );
  }
}
