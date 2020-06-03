import TeamValidations from "../validations/team";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import ModalForm from "./modal-form";

export default class AccountForm extends ModalForm {
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

  setupModal(element, args) {
    super.setupModal(element, args)
  }

  abort() {
    this.router.transitionTo("index");
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */

    if (this.isNewRecord) {
      window.location.replace("/teams/" + savedRecords[0].id);
    } else {
      let href = window.location.href
      window.location.replace(href.substring(0, href.search('#')));
    }
  }
}
