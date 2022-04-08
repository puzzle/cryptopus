import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../../config/environment";

export default class Table extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  constructor() {
    super(...arguments);

    this.store.query("logs", {
        encryptableId: this.args.encryptable.id
      });

    window.scrollTo(0, 0);
  }
}
