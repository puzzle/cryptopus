import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class LogComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;
  @tracked
  personal_log

  constructor() {
    super(...arguments);
    this.store
      .query("paper-trail-version").then((result)=>{this.personal_log = result});
  }
}
