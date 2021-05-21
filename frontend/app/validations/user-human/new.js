import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export default {
  username: [validatePresence(true), validateLength({ max: 20 })],
  givenname: [validatePresence(true)],
  surname: [validatePresence(true)],
  password: [validatePresence(true)]
};
