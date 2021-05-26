import Component from "@ember/component";
import { action } from "@ember/object";

export default class SettingMultiselect extends Component {

  @action
  save() {
    console.log("TEST");
  }
}
