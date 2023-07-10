import Model, { attr, hasMany } from "@ember-data/model";

export default class Team extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") type;
  @attr("string") encryptionAlgorithm;
  @attr("number") passwordBitsize;
  @attr("boolean") private;
  @attr("boolean") favourised;
  @attr("boolean") deletable;
  @attr("number") unread_count;
  @hasMany("folder", { async: false, inverse: "team" }) folders;
  @hasMany("teammember", { async: false, inverse: "team" }) teammembers;

  get isPersonalTeam() {
    return this.type === "Team::Personal";
  }

  get unreadTransfersInInbox() {
    if (!this.isPersonalTeam) return undefined;
    if (!this?.unread_count) return undefined;
    if (this.unread_count === 0) return undefined;
    const folder = this.folders.filter((folder) => folder.name === "inbox")[0];
    return folder?.unreadTransferredCount
      ? folder.unreadTransferredCount
      : this.unread_count;
  }
}
