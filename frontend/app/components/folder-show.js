import Component from "@ember/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class FolderShowComponent extends Component {
  @service navService;
  @service router;

  @tracked
  isFolderEditing = false;

  get collapsed() {
    this.navService.selectedFolder != this.args.folder;
  }

  @action
  collapse() {
    this.router.transitionTo("teams.index", {
      queryParams: { folder_id: !this.collapsed ? null : this.args.folder.id }
    });
  }

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }
}
