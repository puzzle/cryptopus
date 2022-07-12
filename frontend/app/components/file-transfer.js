import { action } from "@ember/object";
import EncryptableFileValidations from "../validations/encryptable-file";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import { isPresent } from "@ember/utils";
import { isEmpty } from "@ember/utils";
import ENV from "frontend/config/environment";


export default class FileTransfer extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;

  @tracked candidates;

  @tracked hasErrors;

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
    this.changeset.receiver = receiver
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
    this.changeset.save();
    this.notify.info(this.intl.t('flashes.encryptable_transfer.file.transferred'));
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
    this.hasErrors = response.errors.length > 0;
  }

}
