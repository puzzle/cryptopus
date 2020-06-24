import TeamsIndexRoute from "./index";

export default class TeamsShowRoute extends TeamsIndexRoute {
  queryParams = {
    q: {
      refreshModel: true
    }
  };

  templateName = "teams/index";
}
