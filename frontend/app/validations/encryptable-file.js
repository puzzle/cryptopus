import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  folder: [validatePresence(true)],
  team: [validatePresence(true)],
  description: [validateLength({ max: 300 })],
  file: [validatePresence(true)]
};
