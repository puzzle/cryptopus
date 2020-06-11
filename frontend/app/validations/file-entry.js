import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  description: [validateLength({ min: 0, max: 300 })],
  file: [validatePresence(true)]
};
