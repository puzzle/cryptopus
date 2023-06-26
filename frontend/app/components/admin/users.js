import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import ENV from "../../config/environment";

export default class UsersComponent extends Component {
  @service userService;

  @tracked
  isUserNew = false;

  constructor() {
    super(...arguments);
  }

  @action
  toggleUserNew() {
    this.isUserNew = !this.isUserNew;
  }

  @action
  addUser(user) {
    this.unlockedUsers.addObject(user);
    window.location.reload();
  }

  get isUserAllowedToCreateUser() {
    return this.userService.isAdmin && ENV.authProvider === "db";
  }
}
