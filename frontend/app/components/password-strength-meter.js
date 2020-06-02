import { inject as service } from "@ember/service";
import Component from "@ember/component";
import { tracked } from "@glimmer/tracking";
import { isPresent } from "@ember/utils";


export default class PasswordStrengthMeterComponent extends Component {

  @service passwordStrength;

  @tracked score = 0;

  constructor() {
    super(...arguments)

    this.passwordStrength.load();
  }

  didReceiveAttrs() {

    if(isPresent(this.password)) {
      this.passwordStrength.strength(this.password).then(strength => {
        let score = strength.score

        if(score === 0)
          this.score = 10;
        else
          this.score = score * 25;
      });
    } else {
      this.score = 0;
    }
  }

  get progressClass() {
    return "progress-bar-"+this.score;
  }

}
