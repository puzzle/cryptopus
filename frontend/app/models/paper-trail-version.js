import Model, { attr, belongsTo } from "@ember-data/model";

export default class PaperTrailVersion extends Model {
  @attr("string") event;
  @attr("number") userId;
  @attr("string") username;
  @attr("string") createdAt;
  @attr("string") encryptableName;
  @attr("string") folderName;
  @attr("string") teamName;
  @belongsTo("encryptable") encryptable;
}
