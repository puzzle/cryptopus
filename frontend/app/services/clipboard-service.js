import Service from "@ember/service";

export default class ClipboardService extends Service {
  copy(text) {
    // Copying to clipboard is not possible in another way. Even libraries do it with a fake element.
    // We don't use the addon ember-cli-clipboard, as we need to wait for a async call to finish.
    const fakeEl = document.createElement("textarea");
    fakeEl.value = text;
    fakeEl.setAttribute("readonly", "");
    fakeEl.style.position = "absolute";
    fakeEl.style.left = "-9999px";
    document.body.appendChild(fakeEl);
    fakeEl.select();
    document.execCommand("copy");
    document.body.removeChild(fakeEl);
  }
}
