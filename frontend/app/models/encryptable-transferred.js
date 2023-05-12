import Encryptable from "./encryptable";
import { attr } from "@ember-data/model";

export default class EncryptableTransferred extends Encryptable {
  @attr file;
  @attr credential;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }
    const url = `/api/encryptables_transfer`;
    const receiverId = await this.receiver.get("id");
    let opts;
    let promise;

    if (this.description === undefined && this.file === undefined) {
      opts = {
        data: {
          receiver_id: receiverId
        },
        headers: {
          "X-CSRF-Token": this.csrfToken
        }
      };

      promise = this.credential.upload(url, opts);
      promise
        .then((savedRecords) => {
          let data = JSON.parse(savedRecords.body).data;
          this.id = data.id;
          this.name = data.attributes.name;
        })
        .catch(() => {});
    } else {
      opts = {
        data: {
          description: this.description || "",
          file: this.file,
          receiver_id: receiverId
        },
        headers: {
          "X-CSRF-Token": this.csrfToken
        }
      };

      promise = this.file.upload(url, opts);
      promise
        .then((savedRecords) => {
          let data = JSON.parse(savedRecords.body).data;
          this.id = data.id;
          this.name = data.attributes.name;
        })
        .catch(() => {});
    }



    return promise;
  }
}
