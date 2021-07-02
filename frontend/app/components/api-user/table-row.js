import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class TableRow extends Component {
  @service intl;
  @service notify;
  @service store;
  @service fetchService;
  @service clipboardService;

  validityTimes = [
    { label: "profile.api_users.options.one_min", value: 60 },
    { label: "profile.api_users.options.five_mins", value: 300 },
    { label: "profile.api_users.options.twelve_hours", value: 43200 },
    { label: "profile.api_users.options.infinite", value: 0 }
  ];

  get selectedValidFor() {
    return this.validityTimes.find(
      (t) => t.value === this.args.apiUser.validFor
    );
  }

  @action
  toggleApiUser(user) {
    let httpMethod = user.locked ? "delete" : "post";
    return this.fetchService
      .send(`/api/api_users/${user.id}/lock`, { method: httpMethod })
      .then(() => (user.locked = !user.locked));
  }

  @action
  renewApiUser(user) {
    /* eslint-disable no-undef  */
    return this.fetchService
      .send(`/api/api_users/${user.id}/token`, {
        method: "get"
      })
      .then((response) => {
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

  @action
  copyCcliLogin(apiUser) {
    this.fetchService
      .send(`/api/api_users/${apiUser.id}/token`, { method: "GET" })
      .then((response) => {
        response.json().then((json) => {
          this.clipboardService.copy(
            `cry login ${btoa(`${json.token}:${json.username}`)}@${
              window.location.origin
            }`
          );
          this.notify.success(
            this.intl.t("flashes.api.api-users.ccli_login.copied")
          );
        });
      });
  }
}
