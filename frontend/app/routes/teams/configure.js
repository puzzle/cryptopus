import Route from "@ember/routing/route";
import RSVP from "rsvp";

export default class TeamsConfigureRoute extends Route {
  async model(params) {
    return RSVP.hash({
      members: this.store.query("teammember", { teamId: params.team_id }),
      apiUsers: this.store.query("api-user", { teamId: params.team_id }),
      teamId: params.team_id
    });
  }
}
