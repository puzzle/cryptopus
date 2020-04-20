import Component from "@glimmer/component";
import { action } from "@ember/object";

export default class AccountsEditModal extends Component {
  @action
  submitAccounts() {
    let accountsToSave = this.args.accounts
      .toArray()
      .filter(a => a.hasDirtyAttributes);
    accountsToSave[0].save();
  }
}
