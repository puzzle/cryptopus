import { action } from "@ember/object";
import AccountValidations from "../../validations/encryptable";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import BaseFormComponent from "../base-form-component";
import { isPresent } from "@ember/utils";
import { isEmpty } from "@ember/utils";
import { capitalize } from "@ember/string";
import { A } from "@ember/array";
import Component from "@glimmer/component";

export default class Form extends Component {
  @service store;
  @service router;
  @service navService;
  @service userService;
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
    this.notify.info(
      this.intl.t(`flashes.encryptables.ccli_command_copied`)
    );
  }
}
