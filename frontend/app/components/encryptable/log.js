import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { isNone } from "@ember/utils";

export default class LogComponent extends Component {
  constructor() {
    super(...arguments);
  }

  @action
  get encryptableLogs() {
    return `/api/encryptables/${this.args.encryptable.get("id")}/logs`;
  }
}
