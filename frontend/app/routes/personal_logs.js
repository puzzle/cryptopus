import BaseRoute from "./base";
import { inject as service } from "@ember/service";

export default class LogRoute extends BaseRoute {
  @service navService;

  model() {
    return this.store.findAll("paper-trail-version");
  }

  afterModel() {
    this.navService.clear();
  }
}