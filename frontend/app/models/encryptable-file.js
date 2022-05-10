import Encryptable from "./encryptable";
import { attr, belongsTo } from "@ember-data/model";

export default class EncryptableFile extends Encryptable {
  @attr file;
  @belongsTo("encryptable-credential") encryptableCredential;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }
    const url = `/api/encryptables`;
    const credential_id = await this.encryptableCredential.get("id");

    const opts = {
      data: {
        description: this.description || "",
        credential_id: credential_id
      },
      headers: {
        "X-CSRF-Token": this.csrfToken
      }
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
