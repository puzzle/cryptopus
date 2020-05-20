import Route from "@ember/routing/route";
import { getOwner } from '@ember/application';

export default class AccountsRoute extends Route {
  get passwordStrength() {
    return getOwner(this).lookup('service:password-strength');
  }

  beforeModel() {
    return this.passwordStrength.load();
  }
}
