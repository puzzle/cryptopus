import Model, { attr, belongsTo } from "@ember-data/model";

export default class FileEntry extends Model {
  @attr("string") filename;
  @attr("string", { defaultValue: "" }) description;
  @attr file;
  @belongsTo("account") account;

  async save() {
    let url = `/api/accounts/${this.account.get("id")}/file_entries`;
    let opts = {
      data: { description: this.description },
      headers: { "X-CSRF-Token": this.csrfToken }
    };

    return this.file.upload(url, opts);
  }
}
