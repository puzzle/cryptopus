import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { isPresent, isNone } from "@ember/utils";

export default class SideNavBar extends Component {
  @service store;
  @service router;
  @service navSideBar;

  @tracked teams;
  @tracked selectedTeam;
  @tracked selectedFolder;
  @tracked collapsed

  constructor() {
    super(...arguments);

    this.teams = this.args.teams;


    this.selectedTeam = this.navSideBar.selectedTeam();
    this.selectedFolder = this.navSideBar.selectedFolder();

    this.collapsed = isPresent(this.selectedTeam);


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
    if(isNone(this.selectedTeam)) {
      this.collapsed = false;
    }

    if(this.selectedTeam === team) {
      this.collapsed = !this.collapsed;
    } else {
      this.collapsed = false;
      this.navSideBar.setSelectedTeam(team);
      this.selectedTeam = team;
    }
    this.selectedFolder = null;
  }

  @action
  setSelectedFolder(folder) {
    this.navSideBar.setSelectedFolder(folder);
    this.selectedFolder = folder;

  }

}
