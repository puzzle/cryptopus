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
  loaded = 0;

  constructor() {
    super(...arguments);
    this.getLogs();
  }

  @tracked
  canLoadMore = true;

  @action
  getLogs() {
    this.store
      .query("version", {
        load: this.loaded
      })
      .then((res) => {
        this.logs = this.logs.concat(res.toArray());
        this.toggleLoadMore();
      });
  }

  @action
  loadMore() {
    this.loaded += 25;
    this.getLogs();
  }

  toggleLoadMore() {
    this.canLoadMore = this.loaded <= this.logs.length - 25;
  }
}
