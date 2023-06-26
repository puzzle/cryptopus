import AdminRoute from "../admin";

export default class AdminUsersRoute extends AdminRoute {
  model(params) {
    // const locked = Boolean(params["locked"]);
    return this.store.query("user-human", {
      admin: true,
      locked: false
    }).then((entries) => {
      return entries.sortBy("username");
    });
  }
}
