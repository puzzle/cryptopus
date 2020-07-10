import BaseRoute from "@ember/routing/route";

export default class AccountEditRoute extends BaseRoute {
  model(params) {
    return this.store.findRecord("account", params.id);
  }
}
