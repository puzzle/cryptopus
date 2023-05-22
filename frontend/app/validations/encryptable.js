import {
  validatePresence,
  validateLength,
  validateExclusion
} from "ember-changeset-validations/validators";

export const VALUE_LENGTH = 70;

export default {
  name: [validatePresence(true), validateLength({ max: VALUE_LENGTH })],
  cleartextPassword: [
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  cleartextUsername: [
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  cleartextToken: [
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  cleartextPin: [
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  cleartextEmail: [
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  label: [
    validatePresence({ presence: true, on: "value" }),
    validateExclusion({ list: [""] }),
    validateLength({ max: 30 })
  ],
  value: [
    validatePresence({ presence: true, on: "label" }),
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  description: [validateLength({ max: 4000 })],
  folder: [validatePresence(true)]
};
