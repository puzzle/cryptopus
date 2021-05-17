import Model, { attr } from "@ember-data/model";

export default class UserHuman extends Model {
  @attr("string") label;
  @attr("string") username;
  @attr("string") lastLoginAt;
  @attr("string") lastLoginFrom;
  @attr("string") providerUid;
  @attr("string") role;
  @attr("string") auth;
}
