import EncryptableFile from "./encryptable-file";
import { attr } from "@ember-data/model";

export default class FileTransfer extends EncryptableFile {
  @attr file;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }
    const url = `/api/encryptables`;
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
        this.filename = data.attributes.filename;
      })
      .catch(() => {});

    return promise;
  }
}
