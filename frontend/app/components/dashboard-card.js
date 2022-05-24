import Component from "@ember/component";
import { inject as service } from "@ember/service";

export default class DashboardCardComponent extends Component {
  @service userService;

  constructor() {
    super(...arguments);
  }
}
