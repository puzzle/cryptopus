import Model, { attr, belongsTo } from "@ember-data/model";

export default class Account extends Model {
  @attr("string") accountname;
  @belongsTo("group") group;
}
