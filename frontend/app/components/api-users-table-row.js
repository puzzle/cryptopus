import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import ENV from "../config/environment";

export default class ApiUsersTableRow extends Component {
  @service store;

  validityTimes = [
    { label: "profile.api_users.options.one_min", value: 60 },
    { label: "profile.api_users.options.five_mins", value: 300 },
    { label: "profile.api_users.options.twelve_hours", value: 43200 },
    { label: "profile.api_users.options.infinite", value: 0 }
  ];

  get selectedValidFor() {
    return this.validityTimes.find(
      (t) => t.value == this.args.apiUser.validFor
    );
  }

  @action
  toggleApiUser(user) {
    let httpMethod = user.locked ? "delete" : "post";
    /* eslint-disable no-undef  */
    return fetch(`/api/api_users/${user.id}/lock`, {
      method: httpMethod,
      headers: {
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "X-CSRF-Token": ENV.CSRFToken
      }
    }).then(() => (user.locked = !user.locked));
    /* eslint-enable no-undef  */
  }

  @action
  renewApiUser(user) {
    /* eslint-disable no-undef  */
    return fetch(`/api/api_users/${user.id}/token`, {
      method: "get",
      headers: {
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "X-CSRF-Token": ENV.CSRFToken
      }
    }).then((response) => {
      response.json().then((json) => {
        if (this.args.parent.setRenewMessage)
          this.args.parent.setRenewMessage(json.info[0]);
      });
    });
    /* eslint-enable no-undef  */
  }

  @action
  updateApiUser(user) {
    if (user.hasDirtyAttributes) {
      user.save();
    }
  }

  @action
  updateValidFor(user, validityTime) {
    user.validFor = validityTime.value;
    this.updateApiUser(user);
  }
}
