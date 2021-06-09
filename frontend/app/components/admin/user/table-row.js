import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../../../config/environment";

export default class AdminUserTableRowComponent extends Component {
  @service fetchService;
  @service store;

  @tracked isEditing = false;

  ROLES = [
    { key: 'user', name: 'User'}, 
    { key: 'conf_admin', name: 'Conf Admin'}, 
    { key: 'admin', name: 'Admin'}
  ]

  @action
  updateRole(user, role) {
    this.fetchService
      .send(`/api/admin/users/${user.id}/role`, {
        method: "PATCH",
        body: `role=${role.key}`
      })
      .then(() => (user.role = role.key));
  }

  @action
  toggleEditing() {
    this.isEditing = !this.isEditing;
  }

  get selectedRole() {
    return this.ROLES.find((role) => role.key === this.args.user.role);
  }

  get isEditable() {
    return ENV.authProvider === "db" && this.args.user.editable;
  }

  get isDeletable() {
    return ENV.authProvider === "db" && this.args.user.deletable;
  }
}
