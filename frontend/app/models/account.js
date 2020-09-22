import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") accountname;
  @attr("string") description;
  @belongsTo("folder") folder;
  @hasMany("file-entry") fileEntries;

  get isOseSecret() {
    return this.constructor.modelName === "account-ose-secret";
  }
}
