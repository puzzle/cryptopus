import Model, { attr, belongsTo } from "@ember-data/model";
import { isPresent } from "@ember/utils";

export default class Encryptable extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @belongsTo("folder") folder;

  get isOseSecret() {
    return this.constructor.modelName === "encryptable-ose-secret";
  }

  get isCredential() {
    return this.constructor.modelName === "encryptable-credential";
  }

  get isFile() {
    return this.constructor.modelName === "encryptable-file";
  }

  get isFullyLoaded() {
    return isPresent(this.createdAt);
  }
}
