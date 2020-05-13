import Model, { attr } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") accountname;
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") description;
  @attr("string") groupName;
  @attr("string") groupId;
  @attr("string") teamName;
  @attr("string") teamId;
}
