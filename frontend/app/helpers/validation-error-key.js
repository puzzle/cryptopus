import { helper } from "@ember/component/helper";
import { underscore } from "@ember/string";

function validationErrorKey(args) {
  let error = args.flat()[0];
  if (!error) return;

  return `validations.${error.context.description.toLowerCase()}.${underscore(
    error.type
  )}`;
}

export default helper(validationErrorKey);
