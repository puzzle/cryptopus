import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default Service.extend({
  @tracked selectedTeam: null,
  @tracked selectedFolder: null
});
