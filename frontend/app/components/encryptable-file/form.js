import BaseFormComponent from "../base-form-component";
import EncryptableFileValidations from "../../validations/encryptable-file";
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
    if (this.changeset.file.size > 1000000) {
      let msg = this.intl.t("flashes.encryptable_files.uploaded_size_to_high");
      this.notify.error(msg);
    } else if (this.changeset.file.size === 0) {
      let msg = this.intl.t("flashes.encryptable_files.uploaded_file_blank");
      this.notify.error(msg);
    } else if (this.changeset.file.name === "") {
      let msg = this.intl.t("flashes.encryptable_files.uploaded_filename_is_empty");
      this.notify.error(msg);
    } else {
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
