import Model, { attr, hasMany } from "@ember-data/model";

export default class Group extends Model {
  @attr("string") name;
  @attr("string") team;
  @hasMany("account") accounts;
}
