import Model, { attr } from "@ember-data/model";

export default class Teammember extends Model {
  @attr("string") label;
  @attr("number") userId;
  @attr("number") teamId;
  @attr("boolean") deletable;
  @attr("boolean") admin;
}
