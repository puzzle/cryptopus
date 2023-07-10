import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { isNone, isPresent } from "@ember/utils";

export default class SideNavBar extends Component {
  @service store;
  @service router;
  @service navService;
  @service userService;

  @tracked collapsed;
  @tracked showsFavourites = false;

  constructor() {
    super(...arguments);

    this.collapsed = isNone(this.navService.selectedTeam);
    this.showsFavourites = localStorage.getItem("showsFavourites") === "true";
  }

  setupModal(element) {
    /* eslint-disable no-undef  */
    // Attach the event handler to the element
    element.addEventListener("show.bs.collapse", function () {
      // Find visible collapse elements within the parent container
      const visibleCollapses = element.querySelectorAll(".collapse.in");

      // Hide the visible collapse elements
      visibleCollapses.forEach(function (collapse) {
        collapse.classList.remove("in");
      });
    });
    /* eslint-enable no-undef  */
  }

  @action
  setSelectedTeam(team) {
    let alreadyTheSame = this.navService.selectedTeam === team;

    if (alreadyTheSame) this.collapsed = !this.collapsed;
    else {
      this.router.transitionTo("teams.show", team.id).then(() => {
        this.collapsed = false;
      });
    }
  }

  @action
  setSelectedFolder(folder) {
    if (folder.isInboxFolder) {
      folder.unreadTransferredCount = null;
      folder.team.set("unread_count", undefined);
    }

    if (isPresent(this.args.navbar)) {
      this.args.navbar.collapse();
    }

    this.router.transitionTo(
      "teams.folders-show",
      folder.team.get("id"),
      folder.id
    );
  }

  @action
  toggleFavourites(isShowing) {
    localStorage.setItem("showsFavourites", isShowing);
    this.showsFavourites = isShowing;
    this.navService.fetchTeams();
  }
}
