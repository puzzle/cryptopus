import Component from "@glimmer/component";
import { marked } from "marked";

export default class Changelog extends Component {
  text = marked.parse("## This is a test string");

  constructor() {
    super(...arguments);
    const req = new XMLHttpRequest();
    req.open(
      "GET",
      "https://raw.githubusercontent.com/puzzle/cryptopus/master/frontend/markdown/CHANGELOG.md",
      false
    );
    req.addEventListener("load", this.reqListener);
    req.send();
  }

  reqListener() {
    this.text = marked.parse(this.reponseText);
  }
}
