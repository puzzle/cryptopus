import AdminRoute from "../admin";
import RSVP from "rsvp";

export default class AdminUsersRoute extends AdminRoute {
  model() {
    return RSVP.hash({
      lockedUsers: this.store.query("user-human", {
        admin: true,
        locked: true
      }),
      unlockedUsers: this.store.query("user-human", {
        admin: true,
        locked: false
      })
    });
  }
}
