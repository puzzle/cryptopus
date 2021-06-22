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
    if (this.isUserChangingSelfOrRoot())
      return true;

    if (this.userService.isAdmin || this.isConfAdminChangingAdmin()) {
      return false;
    } else {
      return true;
    }
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
        let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
        let successMsg = `${translationKeyPrefix}.flashes.api.admin.users.update.${role.key}`;
        let msg = this.intl.t(successMsg);
        this.notify.success(msg);
      });
  }

  @action
  toggleEditing() {
    this.isEditing = !this.isEditing;
  }

  get selectedRole() {
    return this.ROLES.find((role) => role.key === this.args.user.role);
  }

  isUserChangingSelfOrRoot() {
    return ENV.currentUserId == this.args.user.id || this.args.user.username === "root";
  }

  isConfAdminChangingAdmin() {
    return this.userService.isConfAdmin && this.args.user.role !== "admin";
  }
}
