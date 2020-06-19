import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class DeleteWithConfirmationComponent extends Component {
  @service store;

  get modalId() {
    return `delete-modal-${this.args.record.constructor.modelName}-${this.args.record.id}`;
  }

  @action
  deleteRecord() {
    this.args.record.destroyRecord().then(() => {
      if (this.didDelete) this.didDelete();
    });
  }
}
