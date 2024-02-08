import ApplicationRoute from "../application";

export default ApplicationRoute.extend({
  model(params) {
    return this.store.findRecord("team", params.id);
  }
});
