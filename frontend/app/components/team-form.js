import { action } from "@ember/object";
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

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
      return;
    }
    this.router.transitionTo("index");
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
<<<<<<< HEAD
    // FIXME: go to team show
    this.router.transitionTo("teams");
=======
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */

    if (this.isNewRecord) {
      window.location.replace("/teams/" + savedRecords[0].id);
    } else {
      let href = window.location.href;
      window.location.replace(href.substring(0, href.search("#")));
    }
>>>>>>> Change component calls
  }
}
