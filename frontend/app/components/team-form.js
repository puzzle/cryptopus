import TeamValidations from "../validations/team";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import BaseFormComponent from "./base-form-component";

export default class AccountForm extends BaseFormComponent {
  @service store;
  @service router;

  TeamValidations = TeamValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.team || this.store.createRecord("team");
    this.isNewRecord = this.record.isNew;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(TeamValidations),
      TeamValidations
    );
  }

  abort() {
    this.router.transitionTo("index");
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    // FIXME: go to team show
    this.router.transitionTo("teams");
  }
}
