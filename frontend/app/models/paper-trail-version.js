import Model, { attr, belongsTo } from "@ember-data/model";

export default class PaperTrailVersion extends Model {
  @attr("string") event;
  @attr("number") userId;
  @attr("string") username;
  @attr("string") createdAt;
  @belongsTo("encryptable") encryptable;
}
