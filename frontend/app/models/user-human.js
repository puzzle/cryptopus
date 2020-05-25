import Model, { attr } from "@ember-data/model";

export default class UserHuman extends Model {
  @attr("string") label;
}
