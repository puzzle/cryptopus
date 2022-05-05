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
    const favouriteTeams = await this.getFavouriteTeams(params);
    const teams = await this.getTeams(params);
    const recentCredentials = await this.getRecentCredentials(params);

    return RSVP.hash({
      favouriteTeams,
      teams,
      recentCredentials
    });
  }

  async getFavouriteTeams(params) {
    params["limit"] = 20;
    params["favourite"] = true;
    return await this.store.query("team", params);
  }

  async getTeams(params) {
    params["limit"] = 20;
    params["favourite"] = false;
    return await this.store.query("team", params);
  }

  async getRecentCredentials(params) {
    params["recent"] = true;
    return await this.store.query("encryptable", params);
  }
}
