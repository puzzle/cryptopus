import { action } from "@ember/object";
import AccountValidations from "../../validations/encryptable";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "../base-form-component";
import { isPresent } from "@ember/utils";
import { isEmpty } from "@ember/utils";
import { A } from "@ember/array";

export default class Form extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;
  @service userService;

  @tracked selectedTeam;
  @tracked assignableTeams;

  @tracked Errors;

  AccountValidations = AccountValidations;

  //set display field to true when attribute is set, for creating username is default
  @tracked
  isUsernameFieldActive = this.record.cleartextUsername || this.isNewRecord;

  //set display field to true when attribute is set, for creating password is default
  @tracked
  isPasswordFieldActive = this.record.cleartextPassword || this.isNewRecord;

  //set display field to true when attribute is set
  @tracked
  isPinFieldActive = this.record.cleartextPin;

  //set display field to true when attribute is set
  @tracked
  isTokenFieldActive = this.record.cleartextToken;

  //set display field to true when attribute is set
  @tracked
  isEmailFieldActive = this.record.cleartextEmail;

  //set display field to true when attribute is set
  @tracked
  isCustomAttrFieldActive = this.record.cleartextCustomAttr;

  //create array proxy that ember checks the changes in each loop for dropdown, ember's rendering engine
  // doesn't get notified by using a normal array
  @tracked
  items = A(
    ["additionalField"]
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
    if (value === "username") {
      this.isUsernameFieldActive = false;
      this.items.addObject(value);
      this.changeset.cleartextUsername = null;
    } else if (value === "password") {
      this.isPasswordFieldActive = false;
      this.items.addObject(value);
      this.changeset.cleartextPassword = null;
    } else if (value === "pin") {
      this.isPinFieldActive = false;
      this.items.addObject(value);
      this.changeset.cleartextPin = null;
    } else if (value === "token") {
      this.isTokenFieldActive = false;
      this.items.addObject(value);
      this.changeset.cleartextToken = null;
    } else if (value === "email") {
      this.isEmailFieldActive = false;
      this.items.addObject(value);
      this.changeset.cleartextEmail = null;
    } else if (value === "customAttr") {
      this.isCustomAttrFieldActive = false;
      this.items.addObject(value);
      this.changeset.cleartextCustomAttr = null;
    }
  }

  @action
  addField() {
    if (this.selectedItem === "username") {
      this.isUsernameFieldActive = true;
    } else if (this.selectedItem === "password") {
      this.isPasswordFieldActive = true;
    } else if (this.selectedItem === "pin") {
      this.isPinFieldActive = true;
    } else if (this.selectedItem === "token") {
      this.isTokenFieldActive = true;
    } else if (this.selectedItem === "email") {
      this.isEmailFieldActive = true;
    } else if (this.selectedItem === "customAttr") {
      this.isCustomAttrFieldActive = true;
    }
    this.items.removeObject(this.selectedItem);
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
    if (response.errors.length > 0) {
      //get error message to show correct error in form
      this.Errors = response.errors[0].detail
    }
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
