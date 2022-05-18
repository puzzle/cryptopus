import Service from "@ember/service";
import ENV from "../config/environment";

export default class UserService extends Service {
  get role() {
    return ENV.currentUserRole;
  }

  get username() {
    return ENV.currentUserUsername;
  }

  get isConfAdmin() {
    return this.role === "conf_admin";
  }

  get isAdmin() {
    return this.role === "admin";
  }

  get mayManageSettings() {
    return this.isConfAdmin || this.isAdmin;
  }
}
