import BaseFormComponent from "../../base-form-component";
import UserHumanNewValidations from "../../../validations/user-human/new";
import UserHumanEditValidations from "../../../validations/user-human/edit";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class AdminUserFormComponent extends BaseFormComponent {
  UserHumanNewValidations = UserHumanNewValidations;
  UserHumanEditValidations = UserHumanEditValidations;

  @service userService;

  constructor() {
    super(...arguments);

    this.record = this.args.user || this.store.createRecord("user-human");
    this.isNewRecord = this.record.isNew;

    const validations = this.isNewRecord
      ? UserHumanNewValidations
      : UserHumanEditValidations;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(validations),
      validations
    );
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
      return;
    }
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    if (this.args.onSuccess) this.args.onSuccess(savedRecords[0]);
    this.abort();
  }
}
