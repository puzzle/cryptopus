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
  @tracked selectedGroup;
  @tracked assignableTeams;
  @tracked availableGroups;

  isEditView;
  allTeams;

  AccountValidations = AccountValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.account || this.store.createRecord("account");

    this.changeset = new Changeset(
      this.record,
      lookupValidator(AccountValidations),
      AccountValidations
    );

    this.isEditView = !!this.changeset.id

    this.store.findAll("team").then(teams => {
      this.assignableTeams = teams;
      if (this.isEditView) {
        this.selectedTeam = teams.find(() => this.changeset.teamId)
        this.store.query("group", { teamId: this.selectedTeam.id }).then(groups => {
          this.availableGroups = groups;
          this.selectedGroup = groups.find(() => this.changeset.groupId)
          this.changeset.group = this.selectedGroup;
        });
      }
    });
  }

  get selectableGroups() {
    if (this.isGroupDropdownDisabled) return this.allGroups;
    return this.allGroups.filter(
      group => group.team.get("id") === this.selectedTeam.get("id")
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
  setSelectedTeam(selectedTeam) {
    if (!!selectedTeam) {
      this.selectedTeam = selectedTeam;
      this.changeset.team = selectedTeam;

      this.store.query("group", { teamId: this.selectedTeam.id }).then(groups => {
        this.availableGroups = groups;
        this.setGroup(groups.toArray()[0]);
      });
    }
  }

  get selectedGroup() {
    return this.store.peekRecord(this.changeset.groupId);
  }

  @action
  setGroup(group) {
    if (!!group){
      this.selectedGroup = group;
      this.changeset.groupId = group.id;
    }
  }

  async beforeSubmit() {
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccessful(savedRecords) {
    /* eslint-disable no-undef  */
    $(this.modalElement).modal("hide");
    /* eslint-enable no-undef  */

    if (this.isEditView) {
      let href = window.location.href
      window.location.replace(href.substring(0, href.search('#')));
    } else {
      window.location.replace("/accounts/" + savedRecords[0].id);
    }
  }
}
