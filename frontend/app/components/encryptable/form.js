import { action } from "@ember/object";
import AccountValidations from "../../validations/encryptable";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "../base-form-component";
import { isPresent } from "@ember/utils";
import { isEmpty } from "@ember/utils";
import { capitalize } from "@ember/string";
import { A } from "@ember/array";

export default class Form extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;
  @service userService;
  @service notify;

  @tracked selectedTeam;
  @tracked selectedAttribute = null;

  @tracked assignableTeams;

  @tracked errors;

  AccountValidations = AccountValidations;

  //create array proxy that ember checks the changes in each loop for dropdown, ember's rendering engine
  // doesn't get notified by using a normal array
  @tracked
  inactiveFields = A(
    []
      .concat(
        this.record.cleartextUsername || this.isNewRecord ? [] : ["username"]
      )
      .concat(
        this.record.cleartextPassword || this.isNewRecord ? [] : ["password"]
      )
      .concat(this.record.cleartextToken ? [] : ["token"])
      .concat(this.record.cleartextPin ? [] : ["pin"])
      .concat(this.record.cleartextEmail ? [] : ["email"])
      .concat(this.record.cleartextCustomAttr ? [] : ["customAttr"])
  );

  //set display field to true when attribute is set, for creating username and password is default
  @tracked
  activeFields = A(
    []
      .concat(
        this.record.cleartextUsername || this.isNewRecord ? ["username"] : []
      )
      .concat(
        this.record.cleartextPassword || this.isNewRecord ? ["password"] : []
      )
      .concat(this.record.cleartextToken ? ["token"] : [])
      .concat(this.record.cleartextPin ? ["pin"] : [])
      .concat(this.record.cleartextEmail ? ["email"] : [])
      .concat(this.record.cleartextCustomAttr ? ["customAttr"] : [])
  );

  constructor() {
    super(...arguments);

    this.record =
      this.args.encryptable ||
      this.store.createRecord("encryptable-credential");
    this.isNewRecord = this.record.isNew;

    this.changeset = this.accountChangeset;

    if (this.isNewRecord) {
      this.presetTeamAndFolder();
    }

    if (this.isNewRecord && isPresent(this.args.folder)) {
      this.changeset.folder = this.args.folder;
    }

    this.store.findAll("team").then((teams) => {
      this.assignableTeams = teams;
    });

    this.presetTeamIfFolderSelected();

    if (!this.record.isFullyLoaded)
      this.store.findRecord("encryptable-credential", this.record.id);
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
            (folder) => folder.team.get("id") === this.selectedTeam.get("id")
          )
      : [];
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
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

  @action
  removeField(value) {
    this.changeset[`cleartext${capitalize(value)}`] = null;
    this.inactiveFields.addObject(value);
    this.activeFields.removeObject(value);
  }

  @action
  addField() {
    if (this.selectedAttribute == null) {
      this.notify.info(
        this.intl.t(`flashes.encryptables.selectAdditionalField`)
      );
    } else {
      this.inactiveFields.removeObject(this.selectedAttribute);
      this.activeFields.addObject(this.selectedAttribute);
      this.selectedAttribute = null;
    }
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    this.abort();
    this.saveEditedData(savedRecords);
  }

  saveEditedData(savedRecords) {
    if (isPresent(savedRecords)) {
      if (
        this.isNewRecord ||
        this.router.currentRouteName === "encryptables.show"
      ) {
        this.router.transitionTo("encryptables.show", savedRecords[0].id);
      } else {
        this.navService.setSelectedTeamById(
          savedRecords[0].folder.get("team.id")
        );
        this.navService.setSelectedFolderById(savedRecords[0].folder.get("id"));
        this.router.transitionTo(
          "teams.folders-show",
          savedRecords[0].folder.get("team.id"),
          savedRecords[0].folder.get("id")
        );
      }
    }
  }

  get isEncryptableShowRoute() {
    return this.router.currentRouteName === "encryptables.show";
  }

  handleSubmitError(response) {
    this.errors = response.errors;
  }

  presetTeamIfFolderSelected() {
    if (isPresent(this.changeset.folder)) {
      this.selectedTeam = this.changeset.folder.get("team");
    }
  }

  get accountChangeset() {
    return new Changeset(
      this.record,
      lookupValidator(AccountValidations),
      AccountValidations
    );
  }
}
