import Model, { attr } from "@ember-data/model";

export default class Setting extends Model {
  @attr("string") key;
  @attr() value;
}
