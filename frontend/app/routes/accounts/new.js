import Route from '@ember/routing/route';

export default Route.extend({
  async model() {
    await this.store.findAll("group");
    return this.store.findAll("account");
  }
});
