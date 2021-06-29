import {
  validatePresence,
  validateConfirmation
} from "ember-changeset-validations/validators";

export default {
  oldPassword: [validatePresence(true)],
  newPassword1: [validatePresence(true)],
  newPassword2: [
    validatePresence(true),
    validateConfirmation({ on: "newPassword1" })
  ]
};
