import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class TableComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  @tracked logs = [];
  loadAmount = 25;

  constructor() {
    super(...arguments);
    
    this.getLogs()
  }

  @tracked
  canLoadMore = true;
  
  @action
  getLogs() {
    this.store
      .query("paper-trail-version", {
        load: this.loadAmount
      })
      .then((res) => {
        this.logs = res;
        this.toggleLoadMore();
      });
  }

  @action
  loadMore() {
    this.loadAmount += 25;
    this.getLogs();
  }

  toggleLoadMore() {
    this.canLoadMore = this.loadAmount <= this.logs.length;
  }
}
