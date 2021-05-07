import BaseRoute from "./base";
import ENV from "../config/environment";
import RSVP from "rsvp";

export default class ProfileRoute extends BaseRoute {
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
}
