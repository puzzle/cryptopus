import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class NavService extends Service {
  @tracked selectedTeam = null;
  @tracked selectedFolder = null;

  clear() {
    this.selectedTeam = null;
    this.selectedFolder = null;
  }
}
