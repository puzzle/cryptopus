import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../../../config/environment";

export default class AdminUserTableRowComponent extends Component {
  @service fetchService;
  @service store;
  @service intl;
  @service notify;
  @service userService;

  @tracked isEditing = false;

  ROLES = [
    { key: "user", name: "User" },
    { key: "conf_admin", name: "Conf Admin" },
    { key: "admin", name: "Admin" }
  ];

  constructor() {
    super(...arguments);
  }

  get isRoleEditingDisabled() {
    if (this.isOwnUserOrRoot()) return true;

    return !(this.userService.isAdmin || this.isConfAdminChangingAdmin());
  }

  get availableRoles() {
    if (this.userService.isAdmin) {
      return this.ROLES;
    } else {
      return this.ROLES.filter((r) => r.key !== "admin");
    }
  }

  @action
  updateRole(user, role) {
    this.fetch
      .send(`/api/admin/users/${user.id}/role`, {
        method: "PATCH",
        body: `role=${role.key}`
      })
      .then(() => {
        user.role = role.key;
        this.notify.success(
          this.intl.t(`flashes.api.admin.users.update.${role.key}`)
        );
      });
  }

  @action
  toggleEditing() {
    this.isEditing = !this.isEditing;
  }

  @action
  unlockUser(user) {
    this.fetchService
      .send(`/api/admin/users/${user.id}/lock`, {
        method: "DELETE"
      })
      .then(() => {
        user.locked = false;
        if (this.args.onRemove) this.args.onRemove(user);
      });
  }

  get selectedRole() {
    return this.ROLES.find((role) => role.key === this.args.user.role);
  }

  isOwnUserOrRoot() {
    return this.isOwnUser() || this.isRoot();
  }

  isOwnUser() {
    return ENV.currentUserId === this.args.user.id;
  }

  isRoot() {
    return this.args.user.username === "root";
  }

  isConfAdminChangingAdmin() {
    return this.userService.isConfAdmin && this.args.user.role !== "admin";
  }
}
