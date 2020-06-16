import Service from '@ember/service';
import { isPresent } from "@ember/utils";


export default Service.extend({

  selected_team: null,
  selected_folder: null,

  setSelectedTeam(team) {
    this.selected_team = team
  },

  setSelectedFolder(folder) {
    this.selected_folder = folder
  },

  isSelectedTeam(team) {
    return isPresent(this.selected_team) && this.selected_team == team;
  }

});
