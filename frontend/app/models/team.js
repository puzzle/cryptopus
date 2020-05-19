import Model, { attr, hasMany } from "@ember-data/model";

export default class Team extends Model {
  @attr("string") name;
  @attr("string") description;
  @hasMany("group") groups;
  @hasMany("teammember") teammembers;
}
