import BaseRoute from "@ember/routing/route";

export default class EncryptableEditRoute extends BaseRoute {
  model(params) {
    return this.store.findRecord("encryptable", params.id);
  }
}
