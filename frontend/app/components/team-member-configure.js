import BaseFormComponent from "./base-form-component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import ENV from "../config/environment";

export default class TeamMemberConfigureComponent extends BaseFormComponent {
  @service store;
  @service router;
  @service fetchService;

  @tracked members;
  @tracked candidates;
  @tracked apiUsers;

  constructor() {
    super(...arguments);
    this.store.query("teammember", { teamId: this.args.teamId }).then((res) => {
      this.members = res;
    });
    this.store
      .query(
        "team-api-user",
        {
          teamId: this.args.teamId
        },
        { reload: true }
      )
      .then((res) => {
        this.apiUsers = res;
      });

    if (this.args.teamId) {
      this.loadCandidates();
    }
  }

  loadCandidates() {
    this.store
      .query("user-human", {
        teamId: this.args.teamId,
        candidates: true
      })
      .then((res) => (this.candidates = res));
  }

  handleSubmitSuccess() {
    this.store
      .query("teammember", { teamId: this.args.teamId })
      .then((res) => (this.members = res));
    this.loadCandidates();
  }

  showSuccessMessage() {
    this.notify.success(this.intl.t("flashes.api.members.added"));
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
      return;
    }
    this.router.transitionTo("index");
  }

  @action
  search(input) {
    return this.candidates.filter(
      (c) => c.label.toLowerCase().indexOf(input.toLowerCase()) >= 0
    );
  }

  @action
  deleteMember(member) {
    member.teamId = this.args.teamId;
    let isCurrentUser = +member.user.get("id") === ENV.currentUserId;
    member.destroyRecord().then(() => {
      if (isCurrentUser) {
        this.router.transitionTo("index");
        window.location.replace("/teams");
      } else {
        this.store
          .query("teammember", { teamId: this.args.teamId })
          .then((res) => (this.members = res));
        this.loadCandidates();
      }
      this.notify.success(this.intl.t("flashes.api.members.removed"));
    });
  }

  @action
  addMember(member) {
    let team = this.store.peekRecord("team", this.args.teamId);
    let newMember = this.store.createRecord("teammember", {
      user: member,
      team
    });
    this.submit(newMember);
  }

  @action
  toggleApiUser(apiUser) {
    if (apiUser.enabled) {
      this.disableApiUser(apiUser).then(() => (apiUser.enabled = false));
    } else {
      this.enableApiUser(apiUser).then(() => (apiUser.enabled = true));
    }
  }

  enableApiUser(apiUser) {
    return this.fetchService.send(`/api/teams/${this.args.teamId}/api_users`, {
      method: "post",
      body: `id=${apiUser.id}`
    });
  }

  disableApiUser(apiUser) {
    return this.fetchService.send(
      `/api/teams/${this.args.teamId}/api_users/${apiUser.id}`,
      {
        method: "delete"
      }
    );
  }
}
