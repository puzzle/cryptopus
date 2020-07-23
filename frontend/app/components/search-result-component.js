import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class SearchResultComponent extends Component {

  @service navService;
  @service router;

  @action
  clear_search() {
    this.navService.searchQuery = null;
    this.router.replaceWith("index");
  }
}
