import Encryptable from "./encryptable";
import { attr } from "@ember-data/model";

export default class EncryptableOseSecret extends Encryptable {
  @attr("string") oseSecret;
}
