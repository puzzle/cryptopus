import Route from "@ember/routing/route";

export default Route.extend({
  model(params) {
    return this.store.queryRecord("folder", {id: params.id, teamId: params.team_id } );
  }
});
