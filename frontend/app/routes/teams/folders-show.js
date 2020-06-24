import TeamsIndexRoute from "./index";

export default class TeamsFoldersIndexRoute extends TeamsIndexRoute {
  queryParams = {
    q: {
      refreshModel: true
    }
  };

  templateName = "teams/index";
}
