import Component from "@glimmer/component";

export default class UsersComponent extends Component {
  isUserNew = false;

  @action
  toggleUserNew() {
    this.isUserNew = !this.isUserNew;
  }

  @action
  addUser(user) {
    this.users.addObject(user);
  }
}
