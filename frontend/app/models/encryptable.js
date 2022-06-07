import Model, { attr, belongsTo } from "@ember-data/model";

export default class Encryptable extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @belongsTo("folder") folder;

  share(receiver_id) {
    const encryptable_id = this.id;
    const url = `/api/encryptables/` + encryptable_id;

    const opts = {
      data: {
        receiver_id: receiver_id
      },
      headers: {
        "X-CSRF-Token": this.csrfToken
      }
    };

    let promise = this.encryptable.upload(url, opts);
    promise
      .then((savedRecords) => {
        console.log(savedRecords)
      })
      .catch(() => {});

    return promise;
  }

  get isOseSecret() {
    return this.constructor.modelName === "encryptable-ose-secret";
  }

  get isCredential() {
    return this.constructor.modelName === "encryptable-credential";
  }

  get isFile() {
    return this.constructor.modelName === "encryptable-file";
  }
}
