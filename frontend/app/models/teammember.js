import Model, { attr, belongsTo } from "@ember-data/model";

export default class Teammember extends Model {
  @attr("string") label;
  @belongsTo("team") team;
  @belongsTo("user-human") user;
  @attr("boolean") deletable;
  @attr("boolean") admin;
  @attr("boolean") currentUser;
}
