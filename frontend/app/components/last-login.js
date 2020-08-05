import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import ENV from "../config/environment";
import { action } from "@ember/object";


export default class LastLoginComponent extends Component {
  @service notify;

  @action
  lastLoginNotify() {
    let lastUrl = document.referrer
    if (lastUrl.includes('session/new') || lastUrl.includes('session/local')) {
      this.notify.warning(ENV.lastLoginMessage, {closeAfter: null});
    }
  }
}
