import Account from "./account";
import { attr } from "@ember-data/model";

export default class AccountCredential extends Account {
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;

  get isFullyLoaded() {
    return !this.id || !!(this.cleartextUsername || this.cleartextPassword);
  }
}
