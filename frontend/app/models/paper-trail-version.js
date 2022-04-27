import Model, { attr, belongsTo } from "@ember-data/model";

export default class PaperTrailVersion extends Model {
  @attr("string") event;
  @attr("number") user_id;
  @attr("string") username;
  @attr("string") createdAt;
  @attr() object;
  @belongsTo("encryptable") encryptable;
}
