import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class FolderShowComponent extends Component {
  @tracked
  isFolderEditing = false;

  @tracked
  collapsed = true;

  @action
  collapse() {
    this.collapsed = !this.collapsed;
  }

  @action
  toggleFolderEdit() {
    this.isFolderEditing = !this.isFolderEditing;
  }
}
