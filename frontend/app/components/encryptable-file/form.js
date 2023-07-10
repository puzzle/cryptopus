import BaseFormComponent from "../base-form-component";
import EncryptableFileValidations from "../../validations/encryptable-file";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "frontend/config/environment";
import { fileUploadValidation } from "../../helpers/file-upload-validation";

export default class Form extends BaseFormComponent {
  @service store;
  @service router;
  @service fileQueue;

  @tracked errors;

  EncryptableFileValidations = EncryptableFileValidations;

  constructor() {
    super(...arguments);

    this.record = this.store.createRecord("encryptable-file");

    this.changeset = new Changeset(
      this.record,
      lookupValidator(EncryptableFileValidations),
      EncryptableFileValidations
    );

    this.changeset.encryptable = this.args.encryptable;
    this.changeset.csrfToken = ENV.CSRFToken;
  }

  @action
  abort() {
    this.fileQueue.flush();
    if (this.args.onAbort) {
      this.args.onAbort();
      this.args.onHidden();
      return;
    }
  }

  async beforeSubmit() {
    let isFileValid = fileUploadValidation(
      this.changeset.file,
      this.intl,
      this.notify
    );

    if (isFileValid) {
      await this.changeset.validate();
      this.record.encryptableCredential = this.args.encryptableCredential;
      return this.changeset.isValid;
    }
  }

  showSuccessMessage() {
    let msg = this.intl.t("flashes.encryptable_files.uploaded");
    this.notify.success(msg);
  }

  handleSubmitSuccess() {
    this.abort();
  }

  handleSubmitError(response) {
    this.errors = JSON.parse(response.body).errors;
    this.changeset.file = null;
    this.record.encryptableCredential = null;
  }

  @action
  uploadFile(file) {
    this.changeset.file = file;
  }
}
