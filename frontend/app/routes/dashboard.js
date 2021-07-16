import BaseRoute from "./base";
import { inject as service } from "@ember/service";
import RSVP from "rsvp";

export default class DashboardRoute extends BaseRoute {
  @service navService;

  queryParams = {
    q: {
      refreshModel: true
    }
  };

  async model(params) {
    params["limit"] = 20;
    const favouriteTeams = await this.getFavouriteTeams(params);
    const teams = this.getTeams(params);
    return RSVP.hash({
      favouriteTeams,
      teams
    });
  }

  async getFavouriteTeams(params) {
    params["favourite"] = true;
    return await this.store.query("team", params);
  }

  async getTeams(params) {
    params["favourite"] = false;
    return await this.store.query("team", params);
  }
}
