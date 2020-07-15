import BaseRoute from "../base";

export default BaseRoute.extend({
  queryParams: {
    team_id: {
      refreshModel: true
    }
  },

  model(params) {
    return this.store.queryRecord("folder", {
      id: params.id,
      teamId: params.team_id
    });
  }
});
