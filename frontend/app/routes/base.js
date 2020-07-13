import Route from '@ember/routing/route';
import { action } from '@ember/object';
import { inject as service } from "@ember/service";

export default class BaseRoute extends Route {
  @service logoutTimerService

  @action
  didTransition() {
    this.logoutTimerService.start()
    return true; // Bubble the didTransition event
  }
}
