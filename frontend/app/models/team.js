import Model, { attr, hasMany } from "@ember-data/model";

export default class Team extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") type;
  @attr("boolean") private;
  @attr("boolean") favourised;
  @attr("boolean") deletable;
  @attr("number") unread_transferred_files_in_folder;
  @hasMany("folder") folders;
  @hasMany("teammember") teammembers;

  get isPersonalTeam() {
    return this.type === "Team::Personal";
  }

  get unreadTransferredFilesInFolders() {
    if (!this.isPersonalTeam) return 0;

    return this.folders
      .filter((folder) => folder.name === "inbox")
      .reduce(
        (sum, folder) =>
          sum +
          (folder.unreadTransferredFiles ??
            this.unread_transferred_files_in_folder),
        0
      );
  }
}
