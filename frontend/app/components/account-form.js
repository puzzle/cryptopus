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

    this.record = this.args.account

    this.changeset = new Changeset(
      this.record,
      lookupValidator(AccountValidations),
      AccountValidations
    );

    this.isEditView = !!this.changeset.id
    this.title = this.args.title;

    this.store.findAll("team").then(teams => {
      this.assignableTeams = teams;
      this.allTeams = teams;
      if (this.isEditView) {
        this.selectedTeam = teams.filter(team => team.id === this.changeset.team_id)[0];
        this.store.query("group", { team_id: this.selectedTeam.id }).then(groups => {
          this.availableGroups = groups;
          this.selectedGroup = groups.filter(group => group.id === this.changeset.group_id)[0];
          this.changeset.group = this.selectedGroup;
        });
      }
    });
  }

  get selectableGroups() {
    if (this.isGroupDropdownDisabled) return this.allGroups;
    return this.allGroups.filter(
      group => this.id(group.team) === this.id(this.selectedTeam)
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
    this.selectedTeam = selectedTeam;
    this.changeset.team = selectedTeam;
    this.changeset.group = null;
    this.selectedGroup = null;

    this.store.query("group", { team_id: this.selectedTeam.id }).then(groups => {
      this.availableGroups = groups;

      // groups[0] gives undefined, WHAT IS GROUPS?
      this.setGroup(groups.filter(group => true || group)[0]);
    });
  }

  @action
  setGroup(group) {
    this.selectedGroup = group;
    this.changeset.group_id = group.id;
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

  id(object) {
    if (!this.isEditView) {
      return object.get("id");
    }
  }
}
