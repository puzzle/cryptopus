import { action } from "@ember/object";
import TeamValidations from "../../validations/team";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import BaseFormComponent from "../base-form-component";

export default class Form extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;

  TeamValidations = TeamValidations;

  constructor() {
    super(...arguments);

    this.isNewRecord = !this.args.team;
    this.record = this.isNewRecord ? this.store.createRecord("team") : this.args.team;

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
