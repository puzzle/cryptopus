import BaseRoute from "../base";
import { inject as service } from "@ember/service";
import RSVP from "rsvp";

export default class EncryptableShowRoute extends BaseRoute {
  @service navService;

  afterModel() {
    this.navService.clear();
  }

  model(params) {
    return RSVP.hash({
      encryptable: this.store.findRecord("encryptable-credential", params.id),
      encryptableFiles: this.store.query("encryptable-file", {
        credential_id: params.id,
        reload: true
      })
    });
  }
}
