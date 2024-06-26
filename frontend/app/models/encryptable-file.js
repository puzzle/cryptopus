import Encryptable from "./encryptable";
import {attr, belongsTo} from "@ember-data/model";

export default class EncryptableFile extends Encryptable {
  @attr file;
  @belongsTo("encryptable-credential", {async: false, inverse: "encryptableFiles"}) encryptableCredential;
  @belongsTo("folder", {async: false, inverse: "encryptables", as: "encryptable"}) folder;

  async save() {
    if (this.isDeleted) {
      return super.save();
    }
    const url = `/api/encryptables`;
    const opts = await this.getRequestConfig();
    let promise = this.file.upload(url, opts);
    promise
      .then((savedRecords) => {
        savedRecords.json().then((body) => {
          this.id = body.data.id;
          this.name = body.data.attributes.name;
          this.filename = body.data.attributes.filename;
        });
      });
    return promise;
  }

  async getRequestConfig() {
    const credentialId = await this.encryptableCredential?.get("id");
    if (this.folder != null) {
      const folderId = await this.folder.get("id");
      return {
        data: {
          description: this.description || "",
          ...(credentialId !== undefined && {credential_id: credentialId}),
          ...(folderId !== undefined && {folder_id: folderId})
        },
        headers: {
          "X-CSRF-Token": this.csrfToken
        }
      };
    }
    return {
      data: {
        description: this.description || "",
        ...(credentialId !== undefined && {credential_id: credentialId})
      },
      headers: {
        "X-CSRF-Token": this.csrfToken
      }
    };
  }
}
