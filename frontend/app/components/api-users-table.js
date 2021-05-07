import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class ApiUsersTable extends Component {
  @service store;

  @tracked
  renewMessage;

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
}
