import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import UserHumanPasswordEditValidations from "../../validations/user-human/passwordEdit";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import ENV from "../../config/environment";

export default class ProfilePasswordUpdateComponent extends Component {
  @service fetchService;
  @service notify;
  @service intl;

  @tracked isEditing = false;

  UserHumanPasswordEditValidations = UserHumanPasswordEditValidations;

  @tracked
  oldPasswordIncorrectError = "";

  showSuccessMessage() {
    let translationKeyPrefix = this.intl.locale[0].replace("-", "_");
    let successMsg = `${translationKeyPrefix}.flashes.profile.changePassword.success`;
    let msg = this.intl.t(successMsg);
    this.notify.success(msg);
  }

  constructor() {
    super(...arguments);

    let passwordChangeset = {
      oldPassword: "",
      newPassword1: "",
      newPassword2: ""
    };

    this.changeset = new Changeset(
      passwordChangeset,
      lookupValidator(UserHumanPasswordEditValidations),
      UserHumanPasswordEditValidations
    );
  }

  @action
  toggleEditing() {
    this.isEditing = !this.isEditing;
  }

  @action
  resetOldPasswordError() {
    this.oldPasswordIncorrectError = "";
  }

  @action
  async submit() {
    await this.changeset.validate();
    if (!this.changeset.isValid) return;

    const requestBody = {
      data: {
        attributes: {
          old_password: this.changeset.oldPassword,
          new_password1: this.changeset.newPassword1,
          new_password2: this.changeset.newPassword2
        }
      }
    };

    this.fetchService
      .send("/api/profile/password", {
        method: "PATCH",
        headers: {
          Accept: "application/vnd.api+json",
          "Content-Type": "application/json",
          "X-CSRF-Token": ENV.CSRFToken
        },
        body: JSON.stringify(requestBody)
      })
      .then((response) => {
        if (response.ok) {
          this.showSuccessMessage();
          this.toggleEditing();
        } else {
          response.json().then((json) => {
            this.oldPasswordIncorrectError = json.errors[0];
          });
        }
      });
  }

  get isUserAllowedToChangePassword() {
    return ENV.currentUserAuth === "db";
  }
}
