import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class Index extends Component {
  @service navService;

  @tracked model = this.args.model;
  constructor() {
    super(...arguments);
  }
}
