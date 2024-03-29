import Encryptable from "./encryptable";
import { attr } from "@ember-data/model";
import { inject as service } from "@ember/service";

export default class EncryptableTransfer extends Encryptable {
  @attr file;
  @service router;
  @service fetchService;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }
    const targetUrl = `/api/encryptables_transfer`;
    const receiverId = await this.receiver.id;
    let opts;

    if (this.transferringCredentials()) {
      opts = {
        data: {
          receiver_id: receiverId,
          encryptable_id: this.encryptableId
        },
        headers: {
          "X-CSRF-Token": this.csrfToken
        }
      };

      const urlSearchParams = new URLSearchParams(opts.data);
      const body = urlSearchParams.toString();

      return this.fetchService.send(targetUrl, { method: "post", body });
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

      const promise = this.file.upload(targetUrl, opts);
      promise
        .then((savedRecords) => {
          const data = JSON.parse(savedRecords.body).data;
          this.id = data.id;
          this.name = data.attributes.name;
        })
        .catch(() => {});
      return promise;
    }
  }

  transferringCredentials() {
    // this.file is only set, if transferring file
    return this.file === undefined;
  }
}
