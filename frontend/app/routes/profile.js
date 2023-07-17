import ENV from "../config/environment";
import RSVP from "rsvp";
import { inject as service } from "@ember/service";
import ApplicationRoute from "./application";

export default class ProfileRoute extends ApplicationRoute {
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
