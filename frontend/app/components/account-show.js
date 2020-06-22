import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class AccountShowComponent extends Component {
  @service store;
  @service router;

  @tracked
  isPreview = true;

  @tracked
  isAccountEditing = false;

  @action
  swapToCredentialsView() {
    this.isPreview = false;
    this.store.findRecord("account", this.args.account.id);
  }

  @action
  refreshRoute() {
    this.router.transitionTo();
  }

  @action
  toggleAccountEdit() {
    this.isAccountEditing = !this.isAccountEditing;
  }
}
