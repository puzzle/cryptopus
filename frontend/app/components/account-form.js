import { action } from "@ember/object";
import AccountValidations from "../validations/account";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ModalForm from "./modal-form";
import { isPresent } from "@ember/utils";

export default class AccountForm extends ModalForm {
  @service store;
  @service router;

  @tracked selectedTeam;
  @tracked selectedFolder;
  @tracked assignableTeams;
  @tracked availableFolders;

  AccountValidations = AccountValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.account || this.store.createRecord("account");
    this.isNewRecord = this.record.isNew;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(AccountValidations),
      AccountValidations
    );

    this.store.findAll("team").then(teams => {
      this.assignableTeams = teams;
      if (this.isNewRecord) {
        return;
      }

      this.selectedTeam = teams.find(
        team => team.id === this.changeset.folder.get("team.id")
      );
    });
  }

  setupModal(element, args) {
    super.setupModal(element, args);
  }

  abort() {
    this.router.transitionTo("index");
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
    if (isPresent(selectedTeam)) {
      this.selectedTeam = selectedTeam;

      this.store
        .query("folder", { teamId: this.selectedTeam.id })
        .then(folders => {
          this.availableFolders = folders;
          this.setFolder(null);
        });
    }
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
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */

    if (this.isNewRecord) {
      window.location.replace("/accounts/" + savedRecords[0].id);
    } else {
      let href = window.location.href;
      window.location.replace(href.substring(0, href.search("#")));
    }
  }
}
