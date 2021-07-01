import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class AdminUsersTable extends Component {
  @tracked
  isUserNew = false;

  @tracked
  users = [];

  constructor() {
    super(...arguments);

    if (this.args.users) this.users = this.args.users.toArray();
  }

  get sortedUsers() {
    return this.users
      .filter((user) => {
        return !user.isDeleted;
      })
      .sort((userA, userB) => {
        if (userA.username < userB.username) return -1;
        if (userA.username > userB.username) return 1;
        return 0;
      });
  }

  @action
  removeUser(user) {
    this.users.removeObject(user);
  }
}
