import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class ShowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  constructor() {
    super(...arguments);

    this.store.query("file-entry", {
      encryptableId: this.args.encryptable.id
    });

    window.scrollTo(0, 0);
  }

  @tracked
  isEncryptableEditing = false;

  @tracked
  isFileEntryCreating = false;

  @tracked
  isPasswordVisible = false;

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
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
    this.router.transitionTo("/teams");
  }

  @action
  transitionBack() {
    this.router.transitionTo(
      "teams.folders-show",
      this.args.encryptable.folder.get("team.id"),
      this.args.encryptable.folder.get("id")
    );
  }

  @action
  onCopied(attribute) {
    this.notify.info(this.intl.t(`flashes.accounts.${attribute}_copied`));
  }
}
