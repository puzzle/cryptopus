import BaseRoute from "./base";
import { inject as service } from "@ember/service";
import ENV from "../config/environment";

export default class IndexRoute extends BaseRoute {
  @service navService;
  @service notify;

  beforeModel() {
    this.navService.clear()
  }

  model() {
    return ENV.currentUserGivenname;
  }

}
