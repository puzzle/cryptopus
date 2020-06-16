import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { isPresent } from "@ember/utils";


export default class SideNavBar extends Component {
  @service store;
  @service router;
  @service navSideBar;

  @tracked teams;

  constructor() {
    super(...arguments);

    this.teams = this.args.teams;

    /* eslint-disable no-undef  */
    var navSideBarContainer = $('#nav-side-bar-container');
    navSideBarContainer.on('show.bs.collapse','.collapse', function() {
      navSideBarContainer.find('.collapse.in').collapse('hide');
    });
    /* eslint-enable no-undef  */


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
    this.navSideBar.setSelectedTeam(team);
  }

  @action
  setSelectedFolder(folder) {
    this.navSideBar.setSelectedFolder(folder);
    console.log(folder);
  }


  @action
  hasFolders(team) {
    debugger;
    console.log(this.folders);
    return isPresent(this.folders) && this.navSideBar.isSelectedTeam(team);
  }

}
