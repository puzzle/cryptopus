import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Encryptable extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @belongsTo("folder") folder;
  @hasMany("version") versions;

  get isOseSecret() {
    return this.constructor.modelName === "encryptable-ose-secret";
  }

  get isCredential() {
    return this.constructor.modelName === "encryptable-credential";
  }

  get isFile() {
    return this.constructor.modelName === "encryptable-file";
  }
}
