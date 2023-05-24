import Model, { attr, hasMany } from "@ember-data/model";

export default class Team extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") type;
  @attr("boolean") private;
  @attr("boolean") favourised;
  @attr("boolean") deletable;
  @attr("number") unread_count;
  @hasMany("folder") folders;
  @hasMany("teammember") teammembers;

  get isPersonalTeam() {
    return this.type === "Team::Personal";
  }

  get unreadTransfersInInbox() {
    if (!this.isPersonalTeam) return undefined;
    if (this?.unread_count === 0) return undefined;
    const folder = this.folders.filter((folder) => folder.name === "inbox")[0];
    if (!folder?.unreadTransferredCount) return undefined;
    return folder?.unreadTransferredCount
      ? folder.unreadTransferredCount
      : this.unread_count;
  }
}
