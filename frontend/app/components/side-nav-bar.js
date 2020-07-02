import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { isNone } from "@ember/utils";

export default class SideNavBar extends Component {
  @service store;
  @service router;
  @service navService;

  @tracked teams;
  @tracked collapsed;

  constructor() {
    super(...arguments);

    this.teams = this.args.teams;
    this.collapsed = isNone(this.navService.selectedTeam);
  }

  setupModal(element) {
    /* eslint-disable no-undef  */
    $(element).on("show.bs.collapse", ".collapse", function() {
      $(element)
        .find(".collapse.in")
        .collapse("hide");
    });
    /* eslint-enable no-undef  */
  }

  @action
  setSelectedTeam(team) {
    let alreadyTheSame = this.navService.selectedTeam === team;

    if (alreadyTheSame) this.collapsed = !this.collapsed;
    else {
      this.router
        .transitionTo("teams.index", {
          queryParams: { team_id: team.id, folder_id: null }
        })
        .then(() => {
          this.collapsed = false;
        });
    }
  }

  @action
  setSelectedFolder(folder) {
    this.router.transitionTo("teams", {
      queryParams: { folder_id: folder.id }
    });
  }
}
