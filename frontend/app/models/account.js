import Model, { attr } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") accountname;
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") description;
  @attr("string") group_name;
  @attr("string") group_id;
  @attr("string") team_name;
  @attr("string") team_id;
}
