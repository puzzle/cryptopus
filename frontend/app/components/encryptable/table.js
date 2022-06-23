import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class TableComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  constructor() {
    super(...arguments);
  }
}
