import BaseRoute from "../base";

export default BaseRoute.extend({
  model(params) {
    return this.store.findRecord("team", params.id);
  }
});
