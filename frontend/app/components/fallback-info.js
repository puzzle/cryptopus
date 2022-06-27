import Component from "@glimmer/component";
import ENV from "../config/environment";

export default class FallbackInfoComponent extends Component {
  get fallbackInfo() {
    return ENV.fallbackInfo;
  }
}
