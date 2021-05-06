import Service from "@ember/service";
import ENV from "../config/environment";

export default class UserService extends Service {
  get role() {
    return ENV.currentUserRole;
  }

  get isConfAdmin() {
    return this.role === "conf_admin";
  }

  get isAdmin() {
    return this.role === "admin";
  }
}
