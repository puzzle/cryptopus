import BaseRoute from "../base";
import { inject as service } from "@ember/service";
import Ember from 'ember';

export default class EncryptableShowRoute extends BaseRoute {
  @service navService;

  redirect(model) {
    if (model.constructor.modelName === "encryptable-ose-secret") {
      this.transitionTo("teams.folders-show", {
        team_id: model.folder.get("team.id"),
        folder_id: model.folder.get("id")
      });
    }
  }

  afterModel() {
    this.navService.clear();
  }

  model(params) {
    return Ember.RSVP.hash({
      encryptableCredential: this.store.findRecord("encryptable-credential", params.id),
      encryptableFiles: this.store.query('encryptable-file', { credential_id: params.id })
    });
  }
}
