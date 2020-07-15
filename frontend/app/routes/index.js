import BaseRoute from "./base";
import { inject as service } from "@ember/service";

export default class IndexRoute extends BaseRoute {
  @service navService;

  beforeModel() {
    this.navService.clear()
  }
}
