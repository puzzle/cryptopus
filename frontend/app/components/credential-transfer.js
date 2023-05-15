import { action } from "@ember/object";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import ENV from "frontend/config/environment";

export default class CredentialTransfer extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;
  @tracked encryptableId
  @tracked candidates;
  @tracked receiver;

  constructor() {
    super(...arguments);

    this.record = this.store.createRecord("encryptable-transferred");

    this.changeset = new Changeset(this.record);

    this.changeset.csrfToken = ENV.CSRFToken;

    this.encryptableId = this.args.encryptableId;
    this.changeset.encryptableId = this.encryptableId;

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

  showSuccessMessage() {
    let msg = this.intl.t(
      "flashes.encryptable_transfer.encryptable.transferred"
    );
    this.notify.success(msg);
  }

  handleSubmitSuccess() {
    this.abort();
  }

  handleSubmitError(response) {
    this.errors = JSON.parse(response.body).errors;
  }
}
