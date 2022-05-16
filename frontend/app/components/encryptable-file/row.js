import Component from "@glimmer/component";

export default class RowComponent extends Component {
  get downloadLink() {
    return `/api/encryptables/${this.args.encryptableFile.get("id")}`;
  }
}
