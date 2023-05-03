import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Folder extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("number") unreadTransferredFiles;
  @hasMany("encryptable") encryptables;
  @belongsTo("team") team;

  get isInboxFolder() {
    return this.name === "inbox" && this.team.get("isPersonalTeam");
  }
}
