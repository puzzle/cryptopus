import BaseRoute from "./base";
import ENV from "../config/environment";
import RSVP from "rsvp";
import { inject as service } from "@ember/service";

export default class LogRoute extends BaseRoute {
  @service navService;

  model() {
    return RSVP.hash({
      info: {
        lastLoginAt: ENV.currentUserLastLoginAt,
        lastLoginFrom: ENV.currentUserLastLoginFrom,
        currentUserLabel: ENV.currentUserLabel
      },
      apiUsers: this.store.findAll("user-api")
    });
  }
  

  afterModel() {
    this.navService.clear();
  }
}
