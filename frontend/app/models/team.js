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
    console.log("unread Count", this.unread_count)
    if (!this.isPersonalTeam) return undefined;
    if (!this?.unread_count) return undefined;
    const folder = this.folders.filter((folder) => folder.name === "inbox")[0];
    return folder?.unreadTransferredCount
      ? this.unread_count
      : folder.unreadTransferredCount;
  }
}
