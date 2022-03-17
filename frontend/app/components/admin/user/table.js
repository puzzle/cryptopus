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
          if (userA.username < userB.username) return -1;
          if (userA.username > userB.username) return 1;
          return 0;
        });
    }
  }

  /*
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
  */

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
            if (userA.username < userB.username) return -1 * asc;
            if (userA.username > userB.username) return 1 * asc;
            return 0;
          case "givenname":
            if (userA.givenname < userB.givenname) return -1 * asc;
            if (userA.givenname > userB.givenname) return 1 * asc;
            return 0;
          case "last_login_at": // works but could be prettier
            if (userA.lastLoginAt == null && userB.lastLoginAt == null) {
              return 0;
            } else if (userA.lastLoginAt == null) {
              return 1;
            } else if (userB.lastLoginAt == null) {
              return -1;
            } else {
              if (userA.lastLoginAt > userB.lastLoginAt) return -1 * asc;
              if (userA.lastLoginAt < userB.lastLoginAt) return 1 * asc;
              return 0;
            }
          case "last_login_from":
            if (userA.lastLoginFrom == null && userB.lastLoginFrom == null) {
              return 0;
            } else if (userA.lastLoginFrom == null) {
              return 1;
            } else if (userB.lastLoginFrom == null) {
              return -1;
            } else {
              if (userA.lastLoginFrom < userB.lastLoginFrom) return -1 * asc;
              if (userA.lastLoginFrom > userB.lastLoginFrom) return 1 * asc;
              return 0;
            }
          case "auth":
            if (userA.auth < userB.auth) return -1 * asc;
            if (userA.auth > userB.auth) return 1 * asc;
            else {
              if (userA.providerUid == null && userB.providerUid == null)
                return 0;
              else if (userA.providerUid == null) return 1 * asc;
              else if (userB.providerUid == null) return -1 * asc;
              else if (userA.providerUid < userB.providerUid) return 1 * asc;
              else if (userA.providerUid > userB.providerUid) return -1 * asc;
              return 0;
            }
          case "role":
            if (userA.role < userB.role) return -1 * asc;
            if (userA.role > userB.role) return 1 * asc;
            return 0;
        }
      });
  }
}
