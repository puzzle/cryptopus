import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class SearchResultComponent extends Component {
  @service navService;
  @service router;

  @action
  clearSearch() {
    this.navService.clearSearch();
    this.router.replaceWith("index");
  }
}
