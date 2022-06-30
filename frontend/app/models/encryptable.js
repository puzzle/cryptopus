import Model, { attr, belongsTo } from "@ember-data/model";


export default class Encryptable extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @belongsTo("folder") folder;

  get isOseSecret() {
    return this.type === "encryptable-ose-secret";
  }

  get isCredential() {
    return this.type === "encryptable-credential";
  }

  get isFile() {
    return this.type === "encryptable-file";
  }

  get type()  {
    return this.constructor.modelName;
  }

}
