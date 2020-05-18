import { action } from "@ember/object";
import TeamValidations from "../validations/team";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import { bind } from "@ember/runloop";
import { isPresent, isNone } from '@ember/utils';

export default class AccountForm extends BaseFormComponent {
  @service store;
  @service router;

  TeamValidations = TeamValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.account || this.store.createRecord("team");
    this.isNewRecord = this.record.isNew;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(TeamValidations),
      TeamValidations
    );

  }

  setupModal(element, args) {
    var context = args[0];
    context.modalElement = element;
    /* eslint-disable no-undef  */
    $(element).on("hidden.bs.modal", bind(context, context.abort));
    $(element).modal("show");
    /* eslint-enable no-undef  */
  }

  abort() {
    this.router.transitionTo("index");
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccessful(savedRecords) {
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
