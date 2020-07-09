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
  @tracked showsFavourites = false;

  constructor() {
    super(...arguments);

    this.teams = this.args.teams;
    this.collapsed = isNone(this.navService.selectedTeam);
    this.showsFavourites = localStorage.getItem("showsFavourites") === "true";
    this.toggleFavourites(this.showsFavourites);
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
      this.router.transitionTo("teams.show", team.id).then(() => {
        this.collapsed = false;
      });
    }
  }

  @action
  setSelectedFolder(folder) {
    this.router.transitionTo(
      "teams.folders-show",
      folder.team.get("id"),
      folder.id
    );
  }

  @action
  toggleFavourites(isShowing) {
    this.showsFavourites = isShowing;
    localStorage.setItem("showsFavourites", isShowing);
    this.store
      .query("team", {
        favourite: this.showsFavourites ? this.showsFavourites : undefined
      })
      .then(res => (this.teams = res));
  }
}
