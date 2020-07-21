import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  accountname: [validatePresence(true), validateLength({ max: 70 })],
  cleartextPassword: [validateLength({ max: 70 })],
  cleartextUsername: [validateLength({ max: 70 })],
  description: [validateLength({ max: 4000 })],
  folder: [validatePresence(true)]
};
