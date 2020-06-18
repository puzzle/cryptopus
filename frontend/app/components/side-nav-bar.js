import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { not } from '@ember/object/computed';
import { compare, isNone } from "@ember/utils";

export default class SideNavBar extends Component {
  @service store;
  @service router;
  @service navService;

  @tracked teams;
  @tracked collapsed

  constructor() {
    super(...arguments);

    this.teams = this.args.teams;
    this.collapsed = isNone(this.navService.selectedTeam);
  }

  setupModal(element) {
    /* eslint-disable no-undef  */
    $(element).on('show.bs.collapse','.collapse', function() {
      $(element).find('.collapse.in').collapse('hide');
    });
    /* eslint-enable no-undef  */
  }

  @action
  setSelectedTeam(team) {
    let already_the_same = this.navService.selectedTeam === team

    this.navService.selectedTeam = team;
    this.navService.selectedFolder = null;

    if (already_the_same)
      this.collapsed = !this.collapsed;
    else
      this.collapsed = false;
      this.router.transitionTo('teams', {
        queryParams: { team_id: team.id }
      });
  }

  @action
  setSelectedFolder(folder) {
    this.navService.selectedFolder = folder;

    this.router.transitionTo('teams',  {
      queryParams: { folder_id: folder.id }
    });

  }

}
