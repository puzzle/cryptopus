import Model, { attr, belongsTo } from "@ember-data/model";

export default class Teammember extends Model {
  @attr("string") label;
  @belongsTo("team", { async: true, inverse: "teammembers" }) team;
  @belongsTo("user-human", { async: true, inverse: null }) user;
  @attr("boolean") deletable;
  @attr("boolean") admin;
}
