import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @belongsTo("folder") folder;
  @hasMany("file-entry") fileEntries;

  get isOseSecret() {
    return this.constructor.modelName === "account-ose-secret";
  }
}
