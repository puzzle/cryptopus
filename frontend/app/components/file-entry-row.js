import Component from "@glimmer/component";

export default class FileEntryRowComponent extends Component {
  get downloadLink() {
    return `/api/accounts/${this.args.fileEntry.account.get(
      "id"
    )}/file_entries/${this.args.fileEntry.id}`;
  }
}
