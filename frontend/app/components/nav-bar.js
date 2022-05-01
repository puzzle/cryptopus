import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import ENV from "../config/environment";

export default class NavBarComponent extends Component {
  @service router;
  @service navService;
  @service screenWidthService;
  @service userService;

  searchInterval;

  get isStartpage() {
    return this.router.currentRouteName === "index";
  }

  get givenname() {
    return ENV.currentUserGivenname;
  }
}
