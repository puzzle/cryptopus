import Account from "./account";
import { attr } from "@ember-data/model";

export default class AccountOseSecret extends Account {
  @attr("string") oseSecret;
}
