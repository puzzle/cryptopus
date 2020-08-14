import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") accountname;
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") description;
  @attr("string", { defaultValue: "regular" }) category;
  @belongsTo("folder") folder;
  @hasMany("file-entry") fileEntries;

  get isOseSecret() {
    return this.category === "openshift_secret";
  }
}
