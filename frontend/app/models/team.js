import Model, { attr, hasMany } from "@ember-data/model";

export default class Team extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") type;
  @attr("string") encryptionAlgorithm;
  @attr("number") passwordBitsize;
  @attr("boolean") private;
  @attr("boolean") favourised;
  @attr("boolean") deletable;
  @hasMany("folder") folders;
  @hasMany("teammember") teammembers;

  get isPersonalTeam() {
    return this.type === "Team::Personal";
  }

  get encryptionAlgorithmImageName() {
    return encryptionAlgorithms[this.encryptionAlgorithm] || 'aes-256';
  }
}
