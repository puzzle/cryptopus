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

    this.store.findAll("team").then((teams) => {
      this.assignableTeams = teams;
    });

    this.changeset.csrfToken = ENV.CSRFToken;
  }

  setDefaults(element, [thisRef]) {
    thisRef.presetTeamAndFolder(thisRef);
    thisRef.changeset.validate();
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

  presetTeamAndFolder(thisRef) {
    let selectedFolder = thisRef.args.folder || thisRef.navService.selectedFolder;
    let selectedTeam =
      selectedFolder?.get("team") || thisRef.navService.selectedTeam;

    if (!isEmpty(selectedTeam)) {
      thisRef.changeset.set("team", selectedTeam);
    }
    if (!isEmpty(selectedFolder)) {
      thisRef.changeset.set("folder", selectedFolder);
    }
  }

  @action
  setSelectedTeam(selectedTeam) {
    this.changeset.set("team", selectedTeam);
    this.setSelectedFolder(null);
  }

  @action
  setSelectedFolder(selectedFolder) {
    this.changeset.folder = selectedFolder;
    this.changeset.set("folder", selectedFolder);
  }

  @action
  abort(byButton) {
    if (this.args.onAbort && byButton) {
      this.args.onAbort();
    }
  }

  async beforeSubmit() {
    let isFileValid = fileUploadValidation(
      this.changeset.file,
      this.intl,
      this.notify
    );

    if (isFileValid) {
      const encryptableCredential = this.args.encryptableCredential;
      if(encryptableCredential) {
        this.changeset.encryptableCredential = encryptableCredential;
      }
      return this.changeset.isValid;
    }
    return false;
  }

  showSuccessMessage() {
    let msg = this.intl.t("flashes.encryptable_files.uploaded");
    this.notify.success(msg);
  }

  handleSubmitSuccess(savedRecords) {
    this.abort(true);
  }

  handleSubmitError(response) {
    this.errors = [{detail: response}];
    response.json().then((data) => {
      this.errors = data.errors;
    });
    this.changeset.file = null;
    this.record.encryptableCredential = null;
  }

  @action
  uploadFile(file) {
    this.changeset.file = file;
    this.errors = [{detail: !!file}];
  }
}
