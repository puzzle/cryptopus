import Encryptable from "./encryptable";
import { attr } from "@ember-data/model";

export default class EncryptableTransferred extends Encryptable {
  @attr file;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }
    const url = `/api/encryptables_transfer`;
    const receiverId = await this.receiver.get("id");

    const opts = {
      data: {
        description: this.description || "",
        file: this.file,
        receiver_id: receiverId
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
        this.name = data.attributes.name;
      })
      .catch(() => {});

    return promise;
  }
}
