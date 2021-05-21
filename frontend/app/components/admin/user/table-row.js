import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../../../config/environment";

export default class AdminUserTableRowComponent extends Component {
  @service fetchService;
  @service store;

  @tracked
  isEditing = false;

  @action
  updateRole(user, role) {
    this.fetchService
      .send(`/api/admin/users/${user.id}/role`, {
        method: "PATCH",
        body: `role=${role}`
      })
      .then(() => (user.role = role));
  }

  @action
  toggleEditing() {
    this.isEditing = !this.isEditing;
  }

  get isEditable() {
    return ENV.authProvider === "db" && this.args.user.editable;
  }

  get isDeletable() {
    return ENV.authProvider === "db" && this.args.user.deletable;
  }
}
