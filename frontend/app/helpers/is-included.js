import { helper } from "@ember/component/helper";

export function isIncluded(params) {
  const [list, searchString] = params;
  return list.includes(searchString);
}

export default helper(isIncluded);
