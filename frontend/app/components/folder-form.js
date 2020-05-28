import { action } from "@ember/object";
import FolderValidations from "../validations/folder";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "./base-form-component";
import { bind } from "@ember/runloop";
import { isPresent } from "@ember/utils";

export default class FolderForm extends BaseFormComponent {
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

    this.store.findAll("team").then(teams => {
      this.assignableTeams = teams;
      if (this.isNewRecord) {
        return;
      }

      this.selectedTeam = teams.find(
        team => team.id === this.changeset.get("team.id")
      );
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
  setSelectedTeam(selectedTeam) {
    if (isPresent(selectedTeam)) {
      this.selectedTeam = selectedTeam;
      this.changeset.team = team;
    }
  }

  @action
  setTeam(team) {
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
      window.location.replace("/teams"+savedRecords[0].team.id+"/folders/" + savedRecords[0].id);
    } else {
      let href = window.location.href;
      window.location.replace(href.substring(0, href.search("#")));
    }
  }
}
