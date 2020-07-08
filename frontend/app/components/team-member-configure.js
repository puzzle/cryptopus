import BaseFormComponent from "./base-form-component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import fetch from "fetch";
import { tracked } from "@glimmer/tracking";
import ENV from "../config/environment";

export default class TeamMemberConfigureComponent extends BaseFormComponent {
  @service store;
  @service router;

  @tracked members;
  @tracked candidates;

  constructor() {
    super(...arguments);
    this.store.query("teammember", { teamId: this.args.teamId }).then(res => {
      this.members = res;
    });
    this.store
      .query("team-api-user", {
        teamId: this.args.teamId
      })
      .then(res => {
        this.apiUsers = res;
      });

    if (this.args.teamId) {
      this.loadCandidates();
    }
  }

  get translationKeyPrefix() {
    return this.intl.locale[0].replace("-", "_");
  }

  loadCandidates() {
    this.store
      .query("user-human", {
        teamId: this.args.teamId,
        candidates: true
      })
      .then(res => (this.candidates = res));
  }

  handleSubmitSuccess() {
    this.store
      .query("teammember", { teamId: this.args.teamId })
      .then(res => (this.members = res));
    this.loadCandidates();
  }

  showSuccessMessage() {
    let successMsg = `${this.translationKeyPrefix}.flashes.api.members.added`;
    let msg = this.intl.t(successMsg);
    this.notify.success(msg);
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
      c => c.label.toLowerCase().indexOf(input.toLowerCase()) >= 0
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
          .query("teammember", {
            teamId: this.args.teamId
          })
          .then(res => (this.members = res));
        this.loadCandidates();
      }
      let successMsg = `${this.translationKeyPrefix}.flashes.api.members.removed`;
      let msg = this.intl.t(successMsg);
      this.notify.success(msg);
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
    /* eslint-disable no-undef  */
    return fetch(`/api/teams/${this.args.teamId}/api_users`, {
      method: "post",
      headers: {
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
      },
      body: `id=${apiUser.id}`
    });
    /* eslint-enable no-undef  */
  }

  disableApiUser(apiUser) {
    /* eslint-disable no-undef  */
    return fetch(`/api/teams/${this.args.teamId}/api_users/${apiUser.id}`, {
      method: "delete",
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
      }
    });
    /* eslint-enable no-undef  */
  }
}
