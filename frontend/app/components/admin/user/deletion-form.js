import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class AdminUserDeletionFormComponent extends Component {
  @service store;
  @service intl;
  @service notify;

  @tracked
  isDeletionFormShown = false;

  @tracked
  onlyTeammemberTeams = false;

  get isDeletionDisabled() {
    return this.onlyTeammemberTeams.length !== 0;
  }

  @action
  toggleDeletionForm() {
    this.isDeletionFormShown = !this.isDeletionFormShown;

    if (this.isDeletionFormShown) {
      this.onlyTeammemberTeams = this.store.query("team", {
        only_teammember_user_id: this.args.user.id
      });
    }
  }

  @action
  deleteTeam(team) {
    team.destroyRecord();
  }

  @action
  deleteUser() {
    let username = this.args.user
    let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
    let successMsg = `${translationKeyPrefix}.flashes.api.admin.users.destroy.success`;
    let msg = this.intl.t(successMsg);
    this.notify.success(msg);

    this.args.user.destroyRecord();
    this.toggleDeletionForm();
  }
}
