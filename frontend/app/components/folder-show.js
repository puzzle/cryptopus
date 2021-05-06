import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isPresent, isEmpty } from "@ember/utils";

export default class FolderShowComponent extends Component {
  @service navService;
  @service router;

  @tracked
  isFolderEditing = false;

  @tracked
  isNewAccount = false;

  @tracked
  expanded_due_to_search = false;

  constructor() {
    super(...arguments);

    if (isPresent(this.navService.searchQuery)) {
      this.expanded_due_to_search = true;
    }
  }

  get collapsed() {
    if (isPresent(this.navService.searchQuery)) {
      return !this.expanded_due_to_search;
    } else {
      return this.navService.selectedFolder !== this.args.folder;
    }
  }

  get shouldRenderAccounts() {
    return !isEmpty(this.args.folder) && !this.collapsed;
  }

  @action
  collapse() {
    if (isPresent(this.navService.searchQuery)) {
      this.expanded_due_to_search = !this.expanded_due_to_search;
    } else {
      if (this.collapsed) {
        this.router.transitionTo(
          "teams.folders-show",
          this.args.folder.team.get("id"),
          this.args.folder.id
        );
      } else {
        this.router.transitionTo("teams.show", this.args.folder.team.get("id"));
      }
    }
  }

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }

  @action
  toggleAccountCreating() {
    this.isNewAccount = !this.isNewAccount;
  }
}
