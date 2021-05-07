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
    let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
    let modelName = pluralize(this.args.record.constructor.modelName).replace(
      "-",
      "_"
    );
    let deletedMsg = `${translationKeyPrefix}.flashes.${modelName}.deleted`;
    let msg = this.intl.t(deletedMsg);
    if (!msg.includes("Missing translation")) {
      this.notify.success(msg);
    }
  }

  showErrorMessage() {
    let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
    let errorMsg = `${translationKeyPrefix}.flashes.api.errors.delete_failed`;
    let msg = this.intl.t(errorMsg);
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
