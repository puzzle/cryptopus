import Model, { attr } from "@ember-data/model";

export default class ApiUser extends Model {
  @attr("string") username;
  @attr("string") description;
  @attr("boolean") enabled;
}
