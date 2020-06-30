import BaseFormComponent from "./base-form-component";
import FileEntryValidations from "../validations/file-entry";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
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

  @action
  abort() {
    this.fileQueue.flush();
    if (this.args.onAbort) {
      this.args.onAbort();
      return;
    }
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess() {
    this.abort();
    // FIXME: refresh page, such that new FileEntry is shown
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
