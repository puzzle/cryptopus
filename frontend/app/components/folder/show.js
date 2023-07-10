import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isPresent, isEmpty } from "@ember/utils";

export default class ShowComponent extends Component {
  @service navService;
  @service router;

  @tracked
  isFolderEditing = false;

  @tracked
  isNewEncryptable = false;

  get shouldRenderEncryptables() {
    return !isEmpty(this.args.folder.encryptables) && !this.isCollapsed;
  }

  @action
  toggleExpanded() {
    if (this.isExpanded) {
      this.collapseSelectedFolder();
    } else {
      this.expandSelectedFolder();
    }
  }

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }

  @action
  toggleEncryptableCreating() {
    this.navService.setSelectedFolderById(this.args.folder.id);
    this.isNewEncryptable = !this.isNewEncryptable;
  }

  expandSelectedFolder() {
    if (this.args.folder.isInboxFolder) {
      this.args.folder.unreadTransferredCount = null;
      this.args.folder.team.set("unread_count", undefined);
    }
    this.router.transitionTo(
      "teams.folders-show",
      this.args.folder.team.get("id"),
      this.args.folder.id
    );
  }

  collapseSelectedFolder() {
    this.router.transitionTo("teams.show", this.args.folder.team.get("id"));
  }

  @action
  scrollToFolder() {
    if (!this.isSelectedFolder) return;

    const FOLDER_ID = this.args.folder.id;
    const element = document.querySelector(`#folder-header-${FOLDER_ID}`);
    const rect = element.getBoundingClientRect();
    const OFFSET = rect.top + document.body.getBoundingClientRect().top - 15;

    window.scrollTo({
      top: OFFSET,
      behavior: "smooth" // Enable smooth scrolling behavior
    });
  }

  get isExpanded() {
    return this.isSearchQueryPresent || this.isSelectedFolder;
  }

  get isSearchQueryPresent() {
    return isPresent(this.navService.searchQuery);
  }

  get isSelectedFolder() {
    return this.navService.selectedFolder === this.args.folder;
  }
}
