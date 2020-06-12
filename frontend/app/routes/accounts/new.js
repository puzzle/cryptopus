import Route from '@ember/routing/route';

export default Route.extend({

  queryParams: {
    folder_id: {
      refreshModel: true
    },
    team_id: {
      refreshModel: true
    }
  },

  model(params) {
    if(params.folder_id && params.team_id)
      return this.store.queryRecord("folder", {teamId: params.team_id, id: params.folder_id } );
  }


});
