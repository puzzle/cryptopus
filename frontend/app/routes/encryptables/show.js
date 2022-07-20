import BaseRoute from "../base";
import { inject as service } from "@ember/service";
import { hash } from "rsvp";

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
    return hash({
      encryptable: this.store.findRecord("encryptable", params.id),
      encryptableFiles: this.store.query("encryptable-file", {
        credential_id: params.id,
        reload: true
      })
    });
  }
}
