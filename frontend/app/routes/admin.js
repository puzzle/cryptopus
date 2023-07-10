import BaseRoute from "./base";
import { inject as service } from "@ember/service";

export default class AdminRoute extends BaseRoute {
  @service userService;
  @service navService;
  @service router;

  beforeModel() {
    if (!this.userService.mayManageSettings) {
      return this.router.transitionTo("index");
    }
  }

  afterModel() {
    this.navService.clear();
  }
}
