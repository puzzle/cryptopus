import { action } from "@ember/object";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { pluralize } from "ember-inflector";

export default class BaseFormComponent extends Component {
  @service intl;
  @service notify;
  @service store;

  @tracked
  record;
  isNewRecord = false;

  /* The beforeSubmit method can be implemented by a subclass as a hook in the submit method
   * beforeSubmit can return a promise of a boolean, which decides whether or not to abort the submit.
   * False will abort, true will continue.
   * If beforeSubmit is not implemented at all, it will never abort.
   * Possible Usage for this hook might be:
   * async beforeSubmit() {
   *   await this.record.validate();
   *   return this.record.isValid;
   * }
   * */
  async beforeSubmit() {}

  /* The handleSubmitError method can be implemented by a subclass as a hook in the submit method
   * It will be called once the record has been submitted and the api returns an error as response. */
  handleSubmitError() {}

  /* The handleSubmitSuccess method can be implemented by a subclass as a hook in the submit method
   * It will be called once the record has been submitted and the api returns an ok as response. */
  handleSubmitSuccess() {}

  /* The afterSubmit method can be implemented by a subclass as a hook in the submit method
   * It will be called once the record has been submitted and the api has returned any response.
   * No matter if it was saved or not */
  afterSubmit() {}

  /* The showSuccessMessage method can be implemented to adjust the success notify message */
  showSuccessMessage() {
    let translationKeySuffix = this.isNewRecord ? "created" : "updated";
    let modelName = pluralize(this.record.constructor.modelName);
    this.notify.success(
      this.intl.t(`flashes.${modelName}.${translationKeySuffix}`)
    );
  }

  @action
  submit(recordsToSave) {
    this.beforeSubmit().then((continueSubmit) => {
      if (!continueSubmit && continueSubmit !== undefined) {
        return;
      }
      recordsToSave = Array.isArray(recordsToSave)
        ? recordsToSave
        : [recordsToSave];

      let notPersistedRecords = recordsToSave.filter(
        (record) => record.hasDirtyAttributes || record.isDirty
      );
      Promise.all(notPersistedRecords.map((record) => record.save()))
        .then((savedRecords) => {
          this.handleSubmitSuccess(savedRecords);
          this.showSuccessMessage();
          this.afterSubmit();
        })
        .catch((error) => {
          this.handleSubmitError(error);
          this.afterSubmit();
        });
    });
  }
}
