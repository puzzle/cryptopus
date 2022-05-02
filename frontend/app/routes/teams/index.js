import BaseRoute from "../base";
import { isPresent } from "@ember/utils";
import { inject as service } from "@ember/service";

export default class TeamsIndexRoute extends BaseRoute {
  @service navService;

  queryParams = {
    q: {
      refreshModel: true
    }
  };

  beforeModel(transition) {
    let params = transition.to.queryParams;
    let definedParamValues = Object.values(params).filter((value) => !!value);
    if (definedParamValues.length === 0) {
      transition.abort();
      this.transitionTo("index");
    } else if (isPresent(params["q"])) {
      this.navService.clearNavSelection();
      this.navService.searchQuery = params["q"];
      this.navService.searchQueryInput = params["q"];
    }
  }

  model(params) {
    params["limit"] = 10;
    params["favourite"] = this.navService.isShowingFavourites;
    return this.store.query("team", params);
  }
}
