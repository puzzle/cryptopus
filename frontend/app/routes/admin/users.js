import AdminRoute from "../admin";
import RSVP from "rsvp";

export default class AdminUsersRoute extends AdminRoute {
  model() {
    return RSVP.hash({
      locked_users: this.store.query("user-human", { admin: true, locked: true }),
      unlocked_users: this.store.query("user-human", { admin: true, unlocked: false })
    });
  }
}
