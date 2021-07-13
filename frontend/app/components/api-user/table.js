import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../../config/environment";

export default class Table extends Component {
  @service store;
  @service fetchService;

  @tracked
  renewMessage;

  @tracked
  defaultCcliApiUserId;

  @action
  createApiUser() {
    this.store
      .createRecord("user-api")
      .save()
      .then((apiUser) => {
        this.apiUsers.addObject(apiUser);
      });
  }

  setRenewMessage(message) {
    this.renewMessage = message;
  }

  setDefaultCcliUser(apiUser) {
    this.fetchService
      .send(`/api/admin/users/${ENV.currentUserId}`, {
        method: "PATCH",
        body: `default_ccli_user_id=${apiUser.id}`
      })
      .then(() => {
        this.defaultCcliApiUserId = apiUser.id
        this.notify.success(
          "hat funktioniert"
        );
      });
  }
}
