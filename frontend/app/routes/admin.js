import { inject as service } from "@ember/service";
import ApplicationRoute from "./application";

export default class AdminRoute extends ApplicationRoute {
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
