import BaseRoute from "./base";
import { inject as service } from "@ember/service";
import ENV from "../config/environment";

export default class IndexRoute extends BaseRoute {
  @service navService;

  beforeModel() {
    this.navService.clear()
  }

  model() {
    return ENV.currentUserGivenname;
  }
}
