import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class RowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service inViewport;

  @tracked
  isEncryptableEditing = false;

  @tracked
  isShown = false;

  @tracked
  isFile = this.args.encryptable.isFile;

  constructor() {
    super(...arguments);
  }

  // get set attribute amount to hide attribute fields in encryptable row when encryptable has more than two attributes
  get getAttributesAmount() {
    return Object.values(this.args?.encryptable?.usedAttrs ?? {}).filter(
      Boolean
    ).length;
  }

  formattedValue(encryptable, attr) {
    let value = "";
    if (encryptable.isPasswordBlank) {
      value = this.intl.t(`encryptable/credential.${attr}_blank`);
    }

    return value;
  }

  @action
  refreshRoute() {
    this.router.transitionTo();
  }

  @action
  toggleEncryptableEdit() {
    this.fetchEncryptable().then(() => {
      this.isEncryptableEditing = !this.isEncryptableEditing;
    });
  }

  fetchEncryptable() {
    return this.store
      .findRecord("encryptable-credential", this.args.encryptable.id, {
        reload: true
      })
      .catch((error) => {
        if (error.message.includes("401"))
          window.location.replace("/session/new");
      });
  }

  get downloadLink() {
    return `/api/encryptables/${this.args.encryptable.get("id")}`;
  }

  @action
  setupInViewport(element) {
    const viewportTolerance = { bottom: 200, top: 200 };
    const { onEnter } = this.inViewport.watchElement(element, {
      viewportTolerance
    });
    // pass the bound method to `onEnter` or `onExit`
    onEnter(this.didEnterViewport.bind(this));
  }

  didEnterViewport() {
    this.isShown = true;
  }

  @action
  transitionToAccount() {
    this.router.transitionTo("encryptables.show", this.args.encryptable.id);
  }

  willDestroy() {
    // need to manage cache yourself if you don't use the mixin
    const loader = document.getElementById(
      `loader-encryptable-${this.args.encryptable.id}`
    );
    this.inViewport.stopWatching(loader);

    super.willDestroy(...arguments);
  }
}
