import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Group extends Model {
  @attr("string") name;
  @hasMany("account") accounts;
  @belongsTo("team") team;
}
