import EmberRouter from "@ember/routing/router";
import config from "./config/environment";

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = "/app/";
}

Router.map(function() {
  this.route("accounts-edit");
});
