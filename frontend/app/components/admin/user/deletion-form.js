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
     this.store.query("team", {
        only_teammember_user_id: this.args.user.id
      }).then((result) => {
        this.onlyTeammemberTeams = result
      })
    }
  }

  @action
  deleteTeam(team) {
    this.onlyTeammemberTeams = this.onlyTeammemberTeams.filter(e=> e != team)
    team.destroyRecord();
  }

  @action
  deleteUser() {
    this.notify.success(this.intl.t("flashes.api.admin.users.destroy.success"));

    this.args.user.destroyRecord();
    this.toggleDeletionForm();
    this.args.afterDelete();
  }
}
