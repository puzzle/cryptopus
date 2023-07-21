import { isPresent } from "@ember/utils";
import { inject as service } from "@ember/service";
import ApplicationRoute from "../application";

export default class TeamsIndexRoute extends ApplicationRoute {
  @service navService;
  @service router;

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
      this.router.transitionTo("index");
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
