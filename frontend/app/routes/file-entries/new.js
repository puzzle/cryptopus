import Route from "@ember/routing/route";

export default class FileEntriesNewRoute extends Route {
  model(params) {
    return this.store.findRecord("account", params.account_id);
  }
}
