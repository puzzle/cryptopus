import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class DeleteWithConfirmationComponent extends Component {
  @service store;

  @tracked
  isOpen = false;

  @action
  toggleModal() {
    this.isOpen = !this.isOpen;
  }

  @action
  deleteRecord() {
    this.args.record.destroyRecord().then(() => {
      if (this.didDelete) this.didDelete();
    });
  }
}
