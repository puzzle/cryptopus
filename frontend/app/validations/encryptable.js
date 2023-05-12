import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  name: [validatePresence(true), validateLength({ max: 70 })],
  cleartextPassword: [validateLength({ max: 70 })],
  cleartextUsername: [validateLength({ max: 70 })],
  cleartextToken: [validateLength({ max: 70 })],
  cleartextPin: [validateLength({ max: 70 })],
  cleartextEmail: [validateLength({ max: 70 })],
  cleartextCustomAttr: [validateLength({ max: 70 })],
  description: [validateLength({ max: 4000 })],
  folder: [validatePresence(true)]
};
