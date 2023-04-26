import { action } from "@ember/object";
import EncryptableFileValidations from "../validations/encryptable-file";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import ENV from "frontend/config/environment";

export default class FileTransfer extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;
  @tracked candidates;
  @tracked receiver;

  @tracked
  isFileCreating = false;

  EncryptableFileValidations = EncryptableFileValidations;

  constructor() {
    super(...arguments);

    this.record = this.store.createRecord("encryptable-transferred");

    this.changeset = new Changeset(
      this.record,
      lookupValidator(EncryptableFileValidations),
      EncryptableFileValidations
    );

    this.changeset.csrfToken = ENV.CSRFToken;

    this.loadCandidates();
  }

  loadCandidates() {
    this.store
      .query("user-human", {
        candidates: true
      })
      .then((res) => (this.candidates = res));
  }

  @action
  toggleFileNew() {
    this.isFileCreating = !this.isFileCreating;
  }

  @action
  uploadFile(file) {
    this.changeset.file = file;
  }

  @action
  selectReceiver(receiver) {
    this.changeset.receiver = receiver;
  }

  @action
  search(input) {
    return this.candidates.filter(
      (c) => c.label.toLowerCase().indexOf(input.toLowerCase()) >= 0
    );
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
    }
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  @action
  submit() {
    this.validateUploadedFile();
  }

  validateUploadedFile() {
    if (this.changeset.file.size > 1000000) {
      let msg = this.intl.t("flashes.encryptable_files.uploaded_size_to_high");
      this.notify.error(msg);
    } else if (this.changeset.file.size === 0) {
      let msg = this.intl.t("flashes.encryptable_files.uploaded_file_blank");
      this.notify.error(msg);
    } else if (this.changeset.file.name === "") {
      let msg = this.intl.t("flashes.encryptable_files.uploaded_filename_is_empty");
      this.notify.error(msg);
    }
    else {
      this.changeset.save();
      this.abort();
      this.showSuccessMessage();
    }
  }

  showSuccessMessage() {
    let msg = this.intl.t("flashes.encryptable_transfer.file.transferred");
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
}
