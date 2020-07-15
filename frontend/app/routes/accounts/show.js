import BaseRoute from "../base";

export default class AccountShowRoute extends BaseRoute {
  model(params) {
    return this.store.findRecord("account", params.id);
  }
}
