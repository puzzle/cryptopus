import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  name: [validatePresence(true), validateLength({ max: 40 })],
  description: [validateLength({ max: 300 })]
};
