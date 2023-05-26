import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  description: [validateLength({ max: 300 })],
  file: [validatePresence(true)],
  receiver: [validatePresence(true)]
};
