import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Folder extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("number") unreadTransferredCount;
  @hasMany("encryptable", { async: false, inverse: "folder" }) encryptables;
  @belongsTo("team", { async: false, inverse: "folders" }) team;

  get isInboxFolder() {
    return this.name === "inbox" && this.team.get("isPersonalTeam");
  }
}
