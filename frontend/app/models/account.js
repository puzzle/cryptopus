import Model, { attr, belongsTo } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") accountname;
  @attr("string") cleartextUsername;
  @attr("string") cleartextPassword;
  @attr("string") description;
  @belongsTo("group") group;
}
