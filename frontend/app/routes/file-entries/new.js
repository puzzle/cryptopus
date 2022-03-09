import BaseRoute from "../base";

export default class FileEntriesNewRoute extends BaseRoute {
  model(params) {
    return this.store.findRecord("encryptable", params.account_id);
  }
}
