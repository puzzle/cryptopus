import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class TableComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  @tracked logs = [];

  constructor() {
    super(...arguments);
    this.store
      .query("paper-trail-version", {
        load: 10
      })
      .then((res) => {
        this.logs = res;
      });
  }
}
