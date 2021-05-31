import Model, { attr } from "@ember-data/model";

export default class SettingsApi extends Model {
    @attr("string") key;
    @attr("string[]") value;
}
