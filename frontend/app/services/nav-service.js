import Service from "@ember/service";
import { isPresent } from "@ember/utils";
import { tracked } from "@glimmer/tracking";

export default Service.extend({
  @tracked selectedTeam: null,
  @tracked selectedFolder: null
});
