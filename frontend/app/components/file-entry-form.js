import BaseFormComponent from "./base-form-component";
import FileEntryValidations from "../validations/file-entry";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { bind } from "@ember/runloop";
import { tracked } from "@glimmer/tracking";

export default class FileEntryForm extends BaseFormComponent {
  @service store;
  @service router;
  @service fileQueue;

  @tracked errors;

  FileEntryValidations = FileEntryValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.fileEntry || this.store.createRecord("file-entry");

    this.changeset = new Changeset(
      this.record,
      lookupValidator(FileEntryValidations),
      FileEntryValidations
    );

    this.changeset.account = this.args.account;

    /* eslint-disable no-undef  */
    var token = $('meta[name="csrf-token"]').attr("content");
    /* eslint-enable no-undef  */
    this.changeset.csrfToken = token;
  }

  setupModal(element, args) {
    var context = args[0];
    context.modalElement = element;
    /* eslint-disable no-undef  */
    $(element).on("hidden.bs.modal", bind(context, context.abort));
    $(element).modal("show");
    /* eslint-enable no-undef  */
  }

  @action
  abort() {
    this.router.transitionTo("index");
    this.fileQueue.flush();
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess() {
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */

    window.location.replace(`/accounts/${this.changeset.account.get("id")}`);
  }

  handleSubmitError(response) {
    this.errors = JSON.parse(response.body).errors;
    this.changeset.file = null;
  }

  @action
  uploadFile(file) {
    this.changeset.file = file;
  }
}
