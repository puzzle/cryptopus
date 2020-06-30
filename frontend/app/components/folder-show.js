import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isPresent } from '@ember/utils';

export default class FolderShowComponent extends Component {
  @service navService;
  @service router;

  @tracked
  isFolderEditing = false;

  get collapsed() {
    return this.navService.selectedFolder != this.args.folder;
  }

  @action
  collapse() {
    this.router.transitionTo("teams.index", {
      queryParams: { folder_id: !this.collapsed ? null : this.args.folder.id }
    });
  }

  get noFolders() {
    return isPresent(this.navService.selectedFolder) && this.navService.selectedFolder.accounts.length === 0;
  }

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }
}
