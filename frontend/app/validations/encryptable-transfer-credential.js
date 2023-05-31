import { validatePresence } from "ember-changeset-validations/validators";

export default {
  receiver: [validatePresence(true)]
};
