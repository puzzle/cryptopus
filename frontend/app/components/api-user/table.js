import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../../config/environment";

export default class Table extends Component {
  @service store;
  @service fetchService;
  @service userService;

  @tracked
  renewMessage;

  @tracked
  defaultCcliApiUserId;

  constructor() {
    super(...arguments);
    this.defaultCcliApiUserId = ENV.currentUserDefaultCcliUserId;
  }

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
    let data = {
      data: { attributes: { default_ccli_user_id: apiUser.id } }
    };

    this.fetchService
      .send(`/api/admin/users/${ENV.currentUserId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": ENV.CSRFToken
        },
        body: JSON.stringify(data)
      })
      .then(() => {
        this.defaultCcliApiUserId = apiUser.id;
      });
  }

  get isAllowedToUpdateDefaultCcliUser() {
    return this.userService.isAdmin && ENV.currentUserGivenname !== "root";
  }
}
