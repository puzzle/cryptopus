import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class SettingsComponent extends Component {
  @service fetchService;
  @tracked selectedOptions = [];

  constructor() {
    super(...arguments);
    this.selectedOptions = this.args.selectedOptions || [];
  }

  @action
  updateSetting(options) {
    this.selectedOptions = options;
    // this.fetchService.send(id, options)
  }
}
