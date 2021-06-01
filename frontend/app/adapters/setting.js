import ApplicationAdapter from "./application";

export default class SettingAdapter extends ApplicationAdapter {
  urlForFindAll() {
    return `/${this.namespace}/admin/settings`;
  }

  urlForUpdateRecord(id) {
    return `/${this.namespace}/admin/settings/${id}`;
  }
}
