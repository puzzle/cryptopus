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

  selectedTeam() {
    return this.selected_team;
  },

  isSelectedTeam(team) {
    return isPresent(this.selected_team) && this.selected_team == team;
  },

  selectedFolder() {
    return this.selected_folder;
  }


});
