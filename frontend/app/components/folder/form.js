import { action } from "@ember/object";
import FolderValidations from "../../validations/folder";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "../base-form-component";
export default class Form extends BaseFormComponent {
  @service store;
  @service router;
  @service navService;
  @service userService;

  @tracked assignableTeams;
  @tracked dropdownTeam;

  FolderValidations = FolderValidations;

  constructor() {
    super(...arguments);

    this.isNewRecord = !this.args.folder;
    if(this.isNewRecord) {
      this.record = this.store.createRecord("folder");
      this.dropdownTeam = this.navService.selectedTeam;
    } else {
      this.record = this.args.folder;
    }

    this.changeset = new Changeset(
      this.record,
      lookupValidator(FolderValidations),
      FolderValidations
    );

    this.store.findAll("team").then((teams) => {
      this.assignableTeams = teams;
    });
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
      return;
    }
  }

  @action
  setSelectedTeam(selectedTeam) {
    this.dropdownTeam = selectedTeam;
  }

  async beforeSubmit() {
    this.changeset.team = this.dropdownTeam;
    await this.changeset.validate();
    return this.changeset.isValid;
  }

  handleSubmitSuccess(savedRecords) {
    this.abort();
    if (this.isNewRecord) {
      let folder = savedRecords[0];
      this.router.transitionTo(
        "teams.folders-show",
        folder.team.get("id"),
        folder.id
      );
    }
  }
}
