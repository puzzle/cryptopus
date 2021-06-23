import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class SettingMultiselectWithCreateComponent extends Component {
  @service fetchService;
  @service store;
  @tracked selectedOptions = [];

  get settingRecord() {
    return this.store.peekAll(this.args.settingModel).firstObject;
  }

  constructor() {
    super(...arguments);

    if (!this.args.selectedOptions) {
      this.store.findAll(this.args.settingModel).then((settings) => {
        const setting = settings.firstObject;
        if (this.args.options && this.args.options.length) {
          this.selectedOptions = this.args.options.filter((option) => {
            return setting.value.includes(option.value);
          });
        } else {
          this.selectedOptions = setting.value.map((value) => {
            return { label: value, value: value };
          });
        }
      });
    } else {
      this.selectedOptions = this.args.selectedOptions;
    }
  }

  @action
  updateSetting(selected) {
    this.selectedOptions = selected;
    this.settingRecord.value = selected.map((option) => {
      return option.value;
    });

    this.settingRecord.save();
  }

  @action
  addSetting(setting) {
    this.selectedOptions.addObject({ label: setting, value: setting });
    this.updateSetting(this.selectedOptions);
  }

  @action
  hideCreateOptionOnInvalidIpOrSameName(term) {
    if (!this.isValidIp(term)) {
      return false;
    }
    let existingOption = this.selectedOptions.find((option) => {
      return option.value === term;
    });
    return !existingOption;
  }

  isValidIp(ipString) {
    const ipv4RGEX =
      /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    const ipv6RGEX =
      /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/;
    const subnetMaskRGEX = /((\d){1,3}\.){3}(\d){1,3}\/(\d){1,3}/;
    return (
      ipv4RGEX.test(ipString) ||
      ipv6RGEX.test(ipString) ||
      subnetMaskRGEX.test(ipString)
    );
  }
}
