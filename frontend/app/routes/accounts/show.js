import BaseRoute from "../base";
import { inject as service } from "@ember/service";

export default class AccountShowRoute extends BaseRoute {
  @service navService;

  afterModel() {
    this.navService.clear();
  }

  model(params) {
    return this.store.findRecord("account", params.id);
  }
}
