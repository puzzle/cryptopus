import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  accountname: [validatePresence(true), validateLength({ min: 0, max: 70 })],
  description: [validateLength({ min: 0, max: 4000 })],
  folder: [validatePresence(true)]
};
