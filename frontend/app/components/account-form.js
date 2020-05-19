import { action } from "@ember/object";
import AccountValidations from "../validations/account";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import { bind } from "@ember/runloop";
import { isPresent } from "@ember/utils";

export default class AccountForm extends BaseFormComponent {
  @service store;
  @service router;
  @service passwordStrength;

  @tracked selectedTeam;
  @tracked selectedGroup;
  @tracked assignableTeams;
  @tracked availableGroups;
  @tracked passwordScore;
  @tracked passwordLabel;

  AccountValidations = AccountValidations;

  @action
  updatePasswordScore() {
    this.passwordStrength.strength(this.changeset.cleartextPassword).then(strength => {
      this.passwordLabel = strength.feedback.warning
      let calculatedScore = strength.score * 0.25;
      if (calculatedScore === 0) {
        this.passwordScore = 0.01;
      } else {
        this.passwordScore = calculatedScore;
      }
    })
  }

  constructor() {
    super(...arguments);

    this.record = this.args.account || this.store.createRecord("account");
    this.isNewRecord = this.record.isNew;
    this.passwordScore = 0.01;

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
        team => team.id === this.changeset.group.get("team.id")
      );
      // this.availableGroups = this.store.query("group", {
      //   teamId: this.selectedTeam.id
      // });
    });
  }


  setupModal(element, args) {
    var context = args[0];
    context.modalElement = element;
    /* eslint-disable no-undef  */
    $(element).on("hidden.bs.modal", bind(context, context.abort));
    $(element).modal("show");
    /* eslint-enable no-undef  */
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
    this.updatePasswordScore();
  }

  @action
  setSelectedTeam(selectedTeam) {
    if (isPresent(selectedTeam)) {
      this.selectedTeam = selectedTeam;

      this.store
        .query("group", { teamId: this.selectedTeam.id })
        .then(groups => {
          this.availableGroups = groups;
          this.setGroup(null);
        });
    }
  }

  @action
  setGroup(group) {
    this.changeset.group = group;
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */

    if (this.isEditView) {
      let href = window.location.href;
      window.location.replace(href.substring(0, href.search("#")));
    } else {
      window.location.replace("/accounts/" + savedRecords[0].id);
    }
  }
}
