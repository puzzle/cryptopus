import { action } from "@ember/object";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import ENV from "frontend/config/environment";
import { fileUploadValidation } from "../helpers/file-upload-validation";
import EncryptableTransferFile from "../validations/encryptable-transfer-file";

export default class FileTransfer extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;
  @tracked candidates;
  @tracked receiver;

  @tracked
  isFileCreating = false;

  constructor() {
    super(...arguments);

    this.record = this.store.createRecord("encryptable-transfer");

    this.changeset = new Changeset(
      this.record,
      lookupValidator(EncryptableTransferFile),
      EncryptableTransferFile
    );

    this.changeset.csrfToken = ENV.CSRFToken;

    this.loadValidation();

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
    this.loadValidation();
  }

  @action
  selectReceiver(receiver) {
    this.changeset.receiver = receiver;
    this.loadValidation();
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

  async loadValidation() {
    await this.changeset.validate();
  }

  validateUploadedFile() {
    let isFileValid = fileUploadValidation(
      this.changeset.file,
      this.intl,
      this.notify
    );

    if (isFileValid) {
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
