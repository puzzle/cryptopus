import Service from "@ember/service";

export default class ClipboardService extends Service {
  copy(text) {
    navigator.clipboard.writeText(text);
  }
}
