import BaseRoute from "./base";
import { inject as service } from "@ember/service";

export default class AdminRoute extends BaseRoute {
  @service userService;

  beforeModel() {
    if (!this.userService.mayManageSettings) {
      return this.transitionTo("index");
    }
  }
}
