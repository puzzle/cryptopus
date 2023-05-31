import BaseRoute from "../base";
import { inject as service } from "@ember/service";
import { hash } from "rsvp";

export default class EncryptableShowRoute extends BaseRoute {
  @service navService;

  afterModel() {
    this.navService.clear();
  }

  model(params) {
    return hash({
      encryptable: this.store.findRecord("encryptable", params.id),
      encryptableFiles: this.store.query("encryptable-file", {
        credential_id: params.id,
        reload: true
      })
    });
  }
}
