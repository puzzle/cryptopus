import Route from "@ember/routing/route";
import RSVP from "rsvp";

export default class AccountShowRoute extends Route {
  model(params) {
    return this.store.findRecord("account", params.id);
  }
}
