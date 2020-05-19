import Route from '@ember/routing/route';
import { getOwner } from '@ember/application';

export default Route.extend({
  get passwordStrength() {
    return getOwner(this).lookup('service:password-strength');
  },

  beforeModel() {
    return this.passwordStrength.load();
  }
});
