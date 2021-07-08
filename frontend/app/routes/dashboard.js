import BaseRoute from "./base";
import {isPresent} from "@ember/utils";
import {inject as service} from "@ember/service";
import RSVP from "rsvp";

export default class DashboardRoute extends BaseRoute {
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
    } else if (isPresent(params["q"])) {
      this.navService.clear();
      this.navService.searchQuery = params["q"];
    }
  }

  model(params) {
    params["limit"] = 20;
    const favouriteTeams = this.getFavouriteTeams(params);
    const teams = this.getTeams(params);
    return RSVP.hash({
      teams,
      favouriteTeams
    });
  }

  getFavouriteTeams(params) {
    params["favourite"] = true;
    return this.store.query("team", params);
  }

  getTeams(params) {
    params["favourite"] = false;
    return this.store.query("team", params);
  }
}
