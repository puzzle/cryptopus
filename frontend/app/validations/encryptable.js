import {
  validatePresence,
  validateLength,
  validateExclusion
} from "ember-changeset-validations/validators";

export default {
  name: [validatePresence(true), validateLength({ max: 70 })],
  cleartextPassword: [
    validateExclusion({ list: [""] }),
    validateLength({ max: 70 })
  ],
  cleartextUsername: [
    validateExclusion({ list: [""] }),
    validateLength({ max: 70 })
  ],
  cleartextToken: [
    validateExclusion({ list: [""] }),
    validateLength({ max: 70 })
  ],
  cleartextPin: [
    validateExclusion({ list: [""] }),
    validateLength({ max: 70 })
  ],
  cleartextEmail: [
    validateExclusion({ list: [""] }),
    validateLength({ max: 70 })
  ],
  label: [
    validatePresence({ presence: true, on: "value" }),
    validateExclusion({ list: [""] }),
    validateLength({ max: 70 })
  ],
  value: [
    validatePresence({ presence: true, on: "label" }),
    validateExclusion({ list: [""] }),
    validateLength({ max: 30 })
  ],
  description: [validateLength({ max: 4000 })],
  folder: [validatePresence(true)]
};
