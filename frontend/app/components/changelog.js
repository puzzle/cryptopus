import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export default class Changelog extends Component {
  @tracked content = "";

  constructor() {
    super(...arguments);
    this.loadMarkdown();
  }

  async loadMarkdown() {
    const response = await fetch("/CHANGELOG.md");
    this.content = await response.text();
  }
}
