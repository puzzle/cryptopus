import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class AdminUsersTable extends Component {
  @tracked
  isUserNew = false;

  @tracked
  users = [];

  sortedBy = "username";

  constructor() {
    super(...arguments);

    if (this.args.users) {
      this.users = this.args.users
        .toArray()
        .filter((user) => {
          return !user.isDeleted;
        })
        .sort((userA, userB) => {
          return userA.username == userB.username
            ? 0
            : userA.username < userB.username
            ? -1
            : 1;
        });
    }
  }

  @action
  removeUser(user) {
    this.users.removeObject(user);
  }

  @action
  sortBy(attribute) {
    let asc;
    if (attribute == this.sortedBy) {
      asc = -1;
      this.sortedBy = "";
    } else {
      asc = 1;
      this.sortedBy = attribute.toString();
    }

    this.users = this.users
      .filter((user) => {
        return !user.isDeleted;
      })
      .sort((userA, userB) => {
        switch (attribute.toString()) {
          case "username":
            return this.sortAttributes(userA.username, userB.username, asc);
          case "givenname":
            return this.sortAttributes(userA.givenname, userB.givenname, asc);
          case "last_login_at":
            if (userA.lastLoginAt == null || userB.lastLoginAt == null) {
              return this.sortWithNull(userA.lastLoginAt, userB.lastLoginAt);
            } else {
              return this.sortAttributes(
                userA.lastLoginAt,
                userB.lastLoginAt,
                asc * -1
              );
            }
          case "last_login_from":
            if (userA.lastLoginFrom == null || userB.lastLoginFrom == null) {
              return this.sortWithNull(
                userA.lastLoginFrom,
                userB.lastLoginFrom
              );
            } else {
              return this.sortAttributes(
                userA.lastLoginFrom,
                userB.lastLoginFrom,
                asc
              );
            }
          case "auth":
            return userA.auth == userB.auth
              ? this.sortWithNull(userA.providerUid, userB.providerUid)
              : this.sortAttributes(userA.auth, userB.auth, asc);
          case "role":
            return this.sortAttributes(userA.role, userB.role, asc);
        }
      });
  }

  sortAttributes(userA, userB, asc) {
    return userA == userB ? 0 : userA < userB ? -1 * asc : 1 * asc;
  }

  sortWithNull(userA, userB) {
    return userA == null && userB == null ? 0 : userA == null ? 1 : -1;
  }
}
