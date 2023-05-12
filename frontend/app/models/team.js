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

  get unreadTransfersInFolder() {
    if (!this.isPersonalTeam) return undefined;
    if (this.unread_count === null) return undefined;

    let folder = this.folders.filter((folder) => folder.name === "inbox")[0];

    if (folder === undefined) return undefined;
    if (folder.unreadTransferredCount === null || this.unread_count === 0)
      return undefined;
    if (folder.unreadTransferredCount === undefined) return this.unread_count;
    return folder.unreadTransferredCount;
  }
}
