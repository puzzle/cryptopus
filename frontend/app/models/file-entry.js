import Model, { attr, belongsTo } from "@ember-data/model";

export default class FileEntry extends Model {
  @attr("string") filename;
  @attr("string", { defaultValue: "" }) description;
  @attr file;
  @belongsTo("encryptable") encryptable;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }

    let url = `/api/encryptables/${this.encryptable.get("id")}/file_entries`;
    let opts = {
      data: { description: this.description },
      headers: { "X-CSRF-Token": this.csrfToken }
    };

    let promise = this.file.upload(url, opts);
    promise
      .then((savedRecords) => {
        let data = JSON.parse(savedRecords.body).data;
        this.id = data.id;
        this.filename = data.attributes.filename;
      })
      .catch(() => {});

    return promise;
  }
}
