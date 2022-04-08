import Model, { attr, belongsTo } from "@ember-data/model";

export default class Log extends Model {
  @attr("string") event;
  @attr("string") whodunnit;
  @attr("string") createdAt;
  @attr("encryptable") object;
  @belongsTo("encryptable") encryptable;
}
