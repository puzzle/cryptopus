import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class UsersComponent extends Component {
  @service userService;

  @tracked
  isUserNew = false;

  @tracked
  unlockedUsers = [];

  constructor() {
    super(...arguments);

    if (this.args.unlockedUsers)
      this.unlockedUsers = this.args.unlockedUsers.toArray();
  }

  @action
  toggleUserNew() {
    this.isUserNew = !this.isUserNew;
  }

  @action
  addUser(user) {
    this.unlockedUsers.addObject(user);
  }

  get isUserAllowedToCreateUser() {
    return this.userService.isAdmin;
  }
}
