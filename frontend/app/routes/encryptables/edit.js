import ApplicationRoute from "../application";

export default class EncryptableEditRoute extends ApplicationRoute {
  model(params) {
    return this.store.findRecord("encryptable", params.id);
  }
}
