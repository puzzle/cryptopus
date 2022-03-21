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

  constructor() {
    super(...arguments);
  }

  get shouldRenderEncryptables() {
    return !isEmpty(this.args.folder) && !this.isCollapsed;
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
    this.scrollToOpenedFolder();
    this.router.transitionTo(
      "teams.folders-show",
      this.args.folder.team.get("id"),
      this.args.folder.id
    );
  }

  collapseSelectedFolder() {
    this.router.transitionTo("teams.show", this.args.folder.team.get("id"));
  }

  scrollToOpenedFolder() {
      const elementId = `folder-header-${this.args.folder.id}`;
      const posTop = document.getElementById(elementId).getBoundingClientRect().bottom;
      window.scrollTo(0, posTop);
  }

  @action
  scrollToFolder() {
    if (this.isExpanded) {
      this.scrollToOpenedFolder();
    }
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
