import Component from "@glimmer/component";

export default class RowComponent extends Component {
  get downloadLink() {
    return `/api/encryptables/${this.args.fileEntry.encryptable.get(
      "id"
    )}/file_entries/${this.args.fileEntry.id}`;
  }
}
