import EmberRouter from "@ember/routing/router";
import config from "./config/environment";

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route("encryptables", function () {
    this.route("new");
    this.route("edit", { path: "/edit/:id" });
    this.route("show", { path: "/:id" });
    this.route(
      "file-entries",
      { path: "/:encryptable_id/file-entries" },
      function () {
        this.route("new");
      }
    );
  });

  this.route("teams", function () {
    this.route("index", { path: "/" });
    this.route("new");
    this.route("show", { path: "/:team_id" });
    this.route("edit", { path: "/:id/edit" });
    this.route("configure", { path: "/:team_id/configure" });
    this.route("folders-show", { path: "/:team_id/folders/:folder_id" });
  });

  this.route("folders", function () {
    this.route("new");
    this.route("edit", { path: "/:id/edit" });
  });

  this.route("profile");
  this.route("dashboard");

  this.route("admin", function () {
    this.route("users");
    this.route("settings");
  });
});
