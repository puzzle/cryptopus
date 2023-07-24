import {
  validatePresence,
  validateLength
} from "ember-changeset-validations/validators";

export const credentialsAttachment = {
  description: [validateLength({ max: 300 })],
  file: [validatePresence(true)]
};

export const encryptableFile = {
  folder: [validatePresence(true)],
  team: [validatePresence(true)],
  description: [validateLength({ max: 300 })],
  file: [validatePresence(true)]
};
