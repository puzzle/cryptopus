import Component from "@glimmer/component";
import { action } from "@ember/object";
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
}
