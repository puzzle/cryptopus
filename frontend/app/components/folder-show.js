import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class FolderShowComponent extends Component {
  @service navService;
  @service router;

  @tracked
  isFolderEditing = false;

  get collapsed() {
    return (
      this.navService.selectedFolder !== this.args.folder &&
      this.navService.searchQuery === null
    );
  }

  @action
  collapse() {
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

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }
}
