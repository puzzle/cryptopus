import BaseRoute from '../base';

export default BaseRoute.extend({

  queryParams: {
    team_id: {
      refreshModel: true
    }
  },

  model(params) {
    if(params.team_id)
      return this.store.findRecord("team", params.team_id );
  }

});
