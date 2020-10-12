import { action } from "@ember/object";
import AccountValidations from "../validations/account";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import { isPresent } from "@ember/utils";
import { isEmpty } from "@ember/utils";

export default class AccountForm extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;

  @tracked selectedTeam;
  @tracked assignableTeams;

  @tracked hasErrors;

  AccountValidations = AccountValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.account || this.store.createRecord("account-credential");
    this.isNewRecord = this.record.isNew;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(AccountValidations),
      AccountValidations
    );

    if (this.isNewRecord) {
      this.presetTeamAndFolder();
    }

    if (this.isNewRecord && isPresent(this.args.folder)) {
      this.changeset.folder = this.args.folder;
    }

    this.store.findAll("team").then(teams => {
      this.assignableTeams = teams;

      if (isPresent(this.changeset.folder)) {
        this.selectedTeam = this.changeset.folder.get("team");
      }
    });
  }

  presetTeamAndFolder() {
    let selectedTeam = this.navService.selectedTeam;
    let selectedFolder = this.navService.selectedFolder;

    this.selectedTeam = selectedTeam;
    if (!isEmpty(selectedFolder)) {
      this.changeset.folder = selectedFolder;
    }
  }

  get availableFolders() {
    return isPresent(this.selectedTeam)
      ? this.store
          .peekAll("folder")
          .filter(
            folder => folder.team.get("id") === this.selectedTeam.get("id")
          )
      : [];
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
      return;
    }
  }

  @action
  setRandomPassword() {
    let pass = "";
    const PASSWORD_CHARS =
      "abcdefghijklmnopqrstuvwxyz!@#$%^&*()-+<>ABCDEFGHIJKLMNOP1234567890";
    for (let i = 0; i < 14; i++) {
      let r = Math.floor(Math.random() * PASSWORD_CHARS.length);
      pass += PASSWORD_CHARS.charAt(r);
    }
    this.changeset.cleartextPassword = pass;
  }

  @action
  setSelectedTeam(selectedTeam) {
    this.selectedTeam = selectedTeam;
    this.setFolder(null);
  }

  @action
  setFolder(folder) {
    this.changeset.folder = folder;
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    this.abort();
    if (this.isNewRecord) {
      this.router.transitionTo("accounts.show", savedRecords[0].id);
    } else if (
      !this.isNewRecord &&
      this.router.currentRouteName === "teams.folders-show"
    ) {
      this.router.transitionTo(
        "teams.folders-show",
        savedRecords[0].folder.get("team.id"),
        savedRecords[0].folder.get("id")
      );
    }
  }

  handleSubmitError(response) {
    this.hasErrors = response.errors.length > 0;
  }
}
