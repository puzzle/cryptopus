import {
  validatePresence,
  validateLength,
  validateExclusion
} from "ember-changeset-validations/validators";

export const VALUE_LENGTH = 200;

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
  cleartextCustomAttr: [
    validatePresence({ presence: true, on: "cleartextCustomAttrLabel" }),
    validateExclusion({ list: [""] }),
    validateLength({ max: VALUE_LENGTH })
  ],
  cleartextCustomAttrLabel: [
    validatePresence({ presence: true, on: "cleartextCustomAttr" }),
    validateExclusion({ list: [""] }),
    validateLength({ max: 30 })
  ],
  description: [validateLength({ max: 4000 })],
  folder: [validatePresence(true)]
};
