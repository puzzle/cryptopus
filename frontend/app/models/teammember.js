import Model, { attr, belongsTo } from "@ember-data/model";

export default class Teammember extends Model {
  @attr("string") label;
  @belongsTo("team", { async: false, inverse: "teammembers" }) team;
  @belongsTo("user-human", { async: false, inverse: null }) user;
  @attr("boolean") deletable;
  @attr("boolean") admin;
}
