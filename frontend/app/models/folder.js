import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Folder extends Model {
  @attr("string") name;
  @hasMany("account") accounts;
  @belongsTo("team") team;
}
