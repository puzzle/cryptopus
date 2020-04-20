import Route from "@ember/routing/route";

export default class AccountsEditRoute extends Route {
  async model() {
    await this.store.findAll("group");
    return this.store.findAll("account");
  }
}
