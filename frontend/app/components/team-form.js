import { action } from "@ember/object";
import TeamValidations from "../validations/team";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import BaseFormComponent from "./base-form-component";

export default class AccountForm extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;

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
    this.abort();
    if (this.isNewRecord) {
      let team = savedRecords[0];
      this.navService.availableTeams.pushObject(team);
      this.router.transitionTo("teams.show", team.id);
    }
  }
}
