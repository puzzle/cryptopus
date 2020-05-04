import { action } from "@ember/object";
import AccountValidations from "../validations/account";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import { bind } from "@ember/runloop";

export default class AccountForm extends BaseFormComponent {
  @service store;
  @service router;

  @tracked selectedTeam;
  @tracked assignableTeams = this.store.findAll("team");
  @tracked allGroups = this.store.findAll("group");

  AccountValidations = AccountValidations;

  constructor() {
    super(...arguments);
    console.log(this.args.account);

    this.record = this.args.account || this.store.createRecord("account");
    this.selectedTeam = this.record.group && this.record.group.team;
    this.changeset = new Changeset(
      this.record,
      lookupValidator(AccountValidations),
      AccountValidations
    );

    this.title = this.args.title;
  }

  get selectableGroups() {
    if (this.isGroupDropdownDisabled) return this.allGroups;
    return this.allGroups.filter(
      group => group.team.get("id") === this.selectedTeam.id
    );
  }

  get isGroupDropdownDisabled() {
    return !this.selectedTeam;
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
  }

  @action
  setSelectedTeam(team) {
    this.selectedTeam = team;
    if (this.changeset.group !== null && this.changeset.group.id !== undefined)
      this.changeset.group = null;
  }

  @action
  setGroup(group) {
    this.changeset.group = group;
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccessful(savedRecords) {
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */
    window.location.replace("/accounts/" + savedRecords[0].id);
  }
}
