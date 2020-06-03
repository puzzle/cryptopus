import { action } from "@ember/object";
import FolderValidations from "../validations/folder";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ModalForm from "./modal-form";
import { isPresent } from "@ember/utils";

export default class FolderForm extends ModalForm {
  @service store;
  @service router;

  @tracked selectedTeam;
  @tracked assignableTeams;

  FolderValidations = FolderValidations;

  constructor() {
    super(...arguments);

    this.record = this.args.folder || this.store.createRecord("folder");

    this.isNewRecord = this.record.isNew;

    this.changeset = new Changeset(
      this.record,
      lookupValidator(FolderValidations),
      FolderValidations
    );

    if(this.isNewRecord && isPresent(this.args.team)) {
      this.changeset.team = this.args.team
    }

    this.store.findAll("team").then(teams => {
      this.assignableTeams = teams;
      if (isPresent(this.changeset.team)) {
        this.selectedTeam = teams.find(
          team => team.id === this.changeset.get("team.id")
        );
      }
    });
  }

  abort() {
    this.router.transitionTo("index");
  }

  @action
  setSelectedTeam(selectedTeam) {
    if (isPresent(selectedTeam)) {
      this.selectedTeam = selectedTeam;
      this.changeset.team = selectedTeam;
    }
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
      window.location.replace("/teams/"+savedRecords[0].team.get('id')+"/folders/" + savedRecords[0].id);
    } else {
      let href = window.location.href;
      window.location.replace(href.substring(0, href.search("#")));
    }
  }
}
