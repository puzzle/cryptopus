import Route from '@ember/routing/route';
import Account from "../../models/account";

export default Route.extend({

  async model(params) {

    var acc = await this.store.query('account', params.id);

    return await this.store.findRecord('account', params.id);
  }

});
