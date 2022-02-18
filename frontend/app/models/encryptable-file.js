import Encryptable from "./encryptable";
import { attr, belongsTo } from "@ember-data/model";

export default class EncryptableOseSecret extends Encryptable {
  @attr file;
  @belongsTo("encryptable-credential") encryptableCredential;
}
