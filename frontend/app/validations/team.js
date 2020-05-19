import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  name: [validatePresence(true), validateLength({ min: 0, max: 40 })],
  description: [validateLength({ min: 0, max: 300 })]
};
