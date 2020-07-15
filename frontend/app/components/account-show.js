import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class AccountShowComponent extends Component {
  @service store;


  constructor() {
    super(...arguments);

    this.store.query("file-entry", {
      accountId: this.args.account.id
    });
  }

  @tracked
  isAccountEditing = false;

  @tracked
  isFileEntryCreating = false;

  @tracked
  isPasswordVisible = false;

  @action
  toggleAccountEdit() {
    this.isAccountEditing = !this.isAccountEditing;
  }

  @action
  toggleFileEntryNew() {
    this.isFileEntryCreating = !this.isFileEntryCreating;
  }

  @action
  showPassword() {
    this.isPasswordVisible = true;
  }

  @action
  refreshRoute() {
    history.back()
  }

  @action
  transitionBack() {
    history.back();
  }
}
