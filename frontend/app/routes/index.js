import { inject as service } from "@ember/service";
import ENV from "../config/environment";
import ApplicationRoute from "./application";

export default class IndexRoute extends ApplicationRoute {
  @service navService;
  @service notify;

  beforeModel() {
    this.navService.clear();
  }

  model() {
    return ENV.currentUserGivenname;
  }
}
