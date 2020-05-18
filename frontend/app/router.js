import EmberRouter from "@ember/routing/router";
import config from "./config/environment";

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function() {
  this.route("accounts", function() {
    this.route("new");
    this.route("edit", { path: '/edit/:id'});
  });

  this.route("teams", function() {
    this.route("new");
    this.route("edit", {path: '/edit/:id'});
    this.route("configure", { path: "/:team_id/configure" });
  });

});
