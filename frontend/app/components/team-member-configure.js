import BaseFormComponent from "./base-form-component";
import { bind } from "@ember/runloop";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import fetch from "fetch";
import { tracked } from "@glimmer/tracking";

export default class TeamMemberConfigureComponent extends BaseFormComponent {
  @service store;
  @service router;

  @tracked members;
  @tracked candidates;

  constructor() {
    super(...arguments);
    this.members = this.store.query("teammember", { teamId: this.args.teamId });
    this.apiUsers = this.store.query("team-api-user", {
      teamId: this.args.teamId
    });

    if (this.args.teamId) {
      this.loadCandidates();
    }
  }

  loadCandidates() {
    this.candidates = this.store.query("user-human", {
      teamId: this.args.teamId,
      candidates: true
    });
  }

  handleSubmitSuccess() {
    this.members = this.store.query("teammember", { teamId: this.args.teamId });
    this.loadCandidates();
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
    member.destroyRecord().then(() => {
      if (member.currentUser) {
        this.router.transitionTo("index");
        window.location.replace("/teams");
      } else {
        this.members = this.store.query("teammember", {
          teamId: this.args.teamId
        });
        this.loadCandidates();
      }
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
