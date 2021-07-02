import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { pluralize } from "ember-inflector";

export default class DeleteWithConfirmationComponent extends Component {
  @service store;
  @service intl;
  @service notify;

  showDeletedMessage() {
    let modelName = pluralize(this.args.record.constructor.modelName).replace(
      "-",
      "_"
    );
    let msg = this.intl.t(`flashes.${modelName}.deleted`);
    if (!msg.includes("Missing translation")) {
      this.notify.success(msg);
    }
  }

  showErrorMessage() {
    let msg = this.intl.t(`flashes.api.errors.delete_failed`);
    if (!msg.includes("Missing translation")) {
      this.notify.error(msg);
    }
  }

  @tracked
  isOpen = false;

  @action
  toggleModal() {
    this.isOpen = !this.isOpen;
  }

  @action
  deleteRecord() {
    this.args.record
      .destroyRecord()
      .then(() => {
        if (this.args.didDelete) this.args.didDelete();
        this.showDeletedMessage();
      })
      .catch(() => {
        this.showErrorMessage();
      });
  }
}
