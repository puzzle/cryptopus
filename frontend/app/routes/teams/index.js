import BaseRoute from "../base";

export default class TeamsIndexRoute extends BaseRoute {
  queryParams = {
    q: {
      refreshModel: true
    }
  };

  beforeModel(transition) {
    let params = transition.to.queryParams;
    let definedParamValues = Object.values(params).filter(value => !!value);
    if (definedParamValues.length === 0) {
      transition.abort();
      this.transitionTo("index");
    }
  }

  model(params) {
    return this.store.query("team", params);
  }
}
