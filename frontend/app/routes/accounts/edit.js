import Route from '@ember/routing/route';
import Account from "../../models/account";

export default Route.extend({

  model(params) {
    var acc = this.store.findRecord('account', params.id);



    return acc;
  }

});
