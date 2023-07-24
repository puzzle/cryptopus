import BaseFormComponent from "../base-form-component";
import {
  credentialsAttachment,
  encryptableFile
} from "../../validations/encryptable-file";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "frontend/config/environment";
import { isPresent, isEmpty } from "@ember/utils";
import { fileUploadValidation } from "../../helpers/file-upload-validation";

export default class Form extends BaseFormComponent {
  @service store;
  @service router;
  @service fileQueue;
  @service navService;

  @tracked assignableTeams;

  @tracked errors;

  constructor() {
    super(...arguments);
    const FileValidation = this.args.attachment
      ? credentialsAttachment
      : encryptableFile;
    this.record = this.store.createRecord("encryptable-file");
    this.record.encryptable = this.args.encryptable;
    this.record.csrfToken = ENV.CSRFToken;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(FileValidation),
      FileValidation
    );

    this.presetTeamAndFolder();

    this.store.findAll("team").then((teams) => {
      this.assignableTeams = teams;
    });
    this.changeset.csrfToken = ENV.CSRFToken;
    console.log(this.changeset);
  }

  get availableFolders() {
    return isPresent(this.changeset.team)
      ? this.store
          .peekAll("folder")
          .filter(
            (folder) => folder.team.get("id") === this.changeset.team.get("id")
          )
      : [];
  }

  presetTeamAndFolder() {
    let selectedFolder = this.args.folder || this.navService.selectedFolder;
    let selectedTeam =
      selectedFolder?.get("team") || this.navService.selectedTeam;

    if (!isEmpty(selectedTeam)) {
      this.changeset.team = selectedTeam;
    }
    if (!isEmpty(selectedFolder)) {
      this.changeset.folder = selectedFolder;
    }
  }

  @action
  setSelectedTeam(selectedTeam) {
    this.changeset.team = selectedTeam;
    this.setSelectedFolder(null);
  }

  @action
  setSelectedFolder(selectedFolder) {
    this.changeset.folder = selectedFolder;
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
    let isFileValid = fileUploadValidation(
      this.changeset.file,
      this.intl,
      this.notify
    );

    if (isFileValid) {
      this.record.encryptableCredential = this.args.encryptableCredential;
      this.record.folder = this.changeset.folder;
      return this.changeset.isValid;
    }
  }
  showSuccessMessage() {
    let msg = this.intl.t("flashes.encryptable_files.uploaded");
    this.notify.success(msg);
  }

  handleSubmitSuccess(savedRecords) {
    this.abort();
    if (!this.args.attachment) {
      this.saveEditedData(savedRecords);
    }
  }

  saveEditedData(savedRecords) {
    if (isPresent(savedRecords)) {
      this.router.transitionTo(
        "encryptables.show",
        JSON.parse(savedRecords[0].body).data.id
      );
    }
  }

  handleSubmitError(response) {
    response.json().then((data) => {
      this.errors = data.errors;
    });
    this.changeset.file = null;
    this.record.encryptableCredential = null;
  }

  @action
  uploadFile(file) {
    this.changeset.file = file;
  }
}
