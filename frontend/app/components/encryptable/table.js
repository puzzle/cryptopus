import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class TableComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  constructor() {
    super(...arguments);

    this.store.query("paper-trail-version", {
        encryptableId: this.args.encryptable.id
      });

    window.scrollTo(0, 0);
  }
}
