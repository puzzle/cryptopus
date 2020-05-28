import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Folder extends Model {
  @attr("string") name;
  @attr("string") description;
  @hasMany("account") accounts;
  @belongsTo("team") team;
}
