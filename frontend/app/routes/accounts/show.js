import BaseRoute from "../base";
import { inject as service } from "@ember/service";

export default class AccountShowRoute extends BaseRoute {
  @service navService;

  redirect(model) {
    if (model.constructor.modelName === "account-ose-secret") {
      this.transitionTo("folders-show", model.folder.get("id"))
      this.transitionTo("teams.folders-show",
        { team_id: model.folder.get("team.id"),
          folder_id: model.folder.get("id") });
    }
  }

  afterModel() {
    this.navService.clear();
  }

  model(params) {
    return this.store.findRecord("account", params.id);
  }
}
