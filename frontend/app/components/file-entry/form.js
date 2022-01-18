import BaseFormComponent from "../base-form-component";
import FileEntryValidations from "../../validations/file-entry";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "frontend/config/environment";

export default class Form extends BaseFormComponent {
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

    this.changeset.encryptable = this.args.encryptable;

    var token = ENV.CSRFToken;
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

  showSuccessMessage() {
    let msg = this.intl.t("flashes.file_entries.uploaded");
    this.notify.success(msg);
  }

  handleSubmitSuccess() {
    this.abort();
  }

  handleSubmitError(response) {
    this.errors = JSON.parse(response.body).errors;
    this.changeset.file = null;
    this.record.encryptable = null;
  }

  @action
  uploadFile(file) {
    this.changeset.file = file;
  }
}
