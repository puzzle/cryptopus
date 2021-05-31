import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class SettingsComponent extends Component {
  @service fetchService;
  @service store;
  @tracked selectedOptions = [];

  get settingRecord() {
    return this.store.peekAll(this.args.settingModel).firstObject
  }

  constructor() {
    super(...arguments);

    if (!this.args.selectedOptions) {
      this.store.findAll(this.args.settingModel).then(settings => {
        const setting = settings.firstObject
        this.selectedOptions = this.args.options.filter(option => {
          return setting.value.includes(option.value)
        })
      })
    }
    else {
      this.selectedOptions = this.args.selectedOptions
    }
  }

  @action
  updateSetting(selected) {
    this.selectedOptions = selected;
    this.settingRecord.value = selected.map(option => { 
      return option.value 
    })

    this.settingRecord.save()
  }
}
