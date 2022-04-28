import BaseRoute from "./base";
import ENV from "../config/environment";
import RSVP from "rsvp";
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
