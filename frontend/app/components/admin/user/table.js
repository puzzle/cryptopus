import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export default class AdminUsersTable extends Component {
  @tracked
  isUserNew = false;

  constructor() {
    super(...arguments);
  }

  get sortedUsers() {
    return this.args.users
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
  toggleUserNew() {
    this.isUserNew = !this.isUserNew;
  }

  @action
  addUser(user) {
    this.users.addObject(user);
  }

  @action
  removeUser(user) {
    this.users.removeObject(user);
  }
}
