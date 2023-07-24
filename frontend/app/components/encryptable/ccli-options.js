import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import Component from "@glimmer/component";

export default class CcliOptions extends Component {
  @service notify;
  @service clipboardService;
  @service intl;

  constructor() {
    super(...arguments);
  }

  @action
  abort() {
    if (this.args.onAbort) {
      this.args.onAbort();
    }
  }

  @action
  copyCommand(command) {
    this.clipboardService.copy(command);
    this.notify.info(this.intl.t(`flashes.encryptables.ccli_command_copied`));
  }
}
