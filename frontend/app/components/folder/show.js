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
  isNewAccount = false;

  @tracked
  isExpanded = this.isSearchQueryPresent() || this.currentFolderIsSelected();

  constructor() {
    super(...arguments);
  }

  get shouldRenderAccounts() {
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
  toggleAccountCreating() {
    this.navService.setSelectedFolderById(this.args.folder.id);
    this.isNewAccount = !this.isNewAccount;
  }

  expandSelectedFolder() {
    this.router.transitionTo(
      "teams.folders-show",
      this.args.folder.team.get("id"),
      this.args.folder.id
    );
  }

  collapseSelectedFolder() {
    this.router.transitionTo("teams.show", this.args.folder.team.get("id"));
  }

  currentFolderIsSelected() {
    return this.navService.selectedFolder === this.args.folder;
  }

  isSearchQueryPresent() {
    return isPresent(this.navService.searchQuery);
  }
}
