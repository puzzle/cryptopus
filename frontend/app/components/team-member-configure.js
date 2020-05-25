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
    this.members = this.args.members;
    if (this.args.teamId) {
      this.loadCandidates();
    }
  }

  setupModal(element, args) {
    var context = args[0];
    context.modalElement = element;
    /* eslint-disable no-undef  */
    $(element).on("hidden.bs.modal", bind(context, context.abort));
    $(element).modal("show");
    /* eslint-enable no-undef  */
  }

  loadCandidates() {
    this.candidates = this.store.query('user-human', { teamId: this.args.teamId, candidates: true })
  }

  abort() {
    this.router.transitionTo("index");
  }

  handleSubmitSuccess() {
    this.members = this.store.query("teammember", { teamId: this.args.teamId });
    this.loadCandidates();
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
      this.members = this.store.query("teammember", {
        teamId: this.args.teamId
      });
      this.loadCandidates();
    });
  }

  @action
  addMember(member) {
    let team = this.store.peekRecord('team', this.args.teamId)
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
