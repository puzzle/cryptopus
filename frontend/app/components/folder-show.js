import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class FolderShowComponent extends Component {
  @tracked
  isFolderEditing = false;

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }
}
