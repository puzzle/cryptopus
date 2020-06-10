import EmberRouter from "@ember/routing/router";
import config from "./config/environment";

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function() {
  this.route("accounts", function() {
    this.route("new");
    this.route("edit", { path: "/edit/:id" });
    this.route(
      "file-entries",
      { path: "/:account_id/file-entries" },
      function() {
        this.route("new");
      }
    );
  });

  this.route("teams", function() {
    this.route("new");
    this.route("edit", { path: "/:id/edit" });
    this.route("configure", { path: "/:team_id/configure" });
    this.route("folders", { path: "" }, function() {
      this.route("new", { path: "/folders/new" });
      this.route("edit", { path: "/:team_id/folders/:id/edit/" });
    });
  });
});
