import Model, { attr, belongsTo } from "@ember-data/model";
import { isPresent } from "@ember/utils";

export default class Encryptable extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @attr("string") sender_name;
  @belongsTo("folder", { async: true, inverse: "encryptables" }) folder;

  get isCredential() {
    return this.constructor.modelName === "encryptable-credential";
  }

  get isFile() {
    return this.constructor.modelName === "encryptable-file";
  }

  get isFullyLoaded() {
    return !this.id || isPresent(this.createdAt);
  }
}
