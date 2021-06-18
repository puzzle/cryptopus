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

  roleEditDisabled = false;

  ROLES = [
    { key: "user", name: "User" },
    { key: "conf_admin", name: "Conf Admin" },
    { key: "admin", name: "Admin" }
  ];

  constructor() {
    super(...arguments);

    this.restrictRoleEditing();
  }

  @action
  updateRole(user, role) {
    this.fetchService
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

  restrictRoleEditing() {
    if (this.isCurrentUser() || this.userService.isConfAdmin) {
      this.roleEditDisabled = true;
    }
  }

  isCurrentUser() {
    return this.currentUserGivennameLowercase === this.args.user.givenname;
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

  get currentUserGivennameLowercase() {
    return ENV.currentUserGivenname.toLowerCase();
  }
}
