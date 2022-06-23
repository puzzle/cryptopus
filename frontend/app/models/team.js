import Model, { attr, hasMany } from "@ember-data/model";

const encryptionAlgorithms = {
  AES256: "aes-256",
  AES256IV: "aes-256-iv"
}

export default class Team extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") type;
  @attr("string") encryptionAlgorithm;
  @attr("boolean") private;
  @attr("boolean") favourised;
  @attr("boolean") deletable;
  @hasMany("folder") folders;
  @hasMany("teammember") teammembers;

  get isPersonalTeam() {
    return this.type === "Team::Personal";
  }

  get encryptionAlgorithmImageName() {
    return encryptionAlgorithms[this.encryptionAlgorithm];
  }
}
