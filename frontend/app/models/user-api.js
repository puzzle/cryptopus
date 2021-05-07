import Model, { attr } from "@ember-data/model";

export default class UserApi extends Model {
  @attr("string") username;
  @attr("string") description;
  @attr("string") validUntil;
  @attr("number") validFor;
  @attr("string") lastLoginAt;
  @attr("string") lastLoginFrom;
  @attr("boolean") locked;
}
