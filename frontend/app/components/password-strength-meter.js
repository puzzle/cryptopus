import { inject as service } from "@ember/service";
import Component from "@ember/component";
import { tracked } from "@glimmer/tracking";
import { isPresent } from "@ember/utils";

export default class PasswordStrengthMeterComponent extends Component {
  @service passwordStrength;

  @tracked barWidth = 0;
  @tracked score = 0;

  constructor() {
    super(...arguments);

    this.passwordStrength.load();
  }

  didReceiveAttrs() {
    if (isPresent(this.password)) {
      this.passwordStrength.strength(this.password).then(strength => {
        this.score = strength.score;

        if(this.password === "")
          this.barWidth = 0;
        else  {
          if (this.score === 0)
            this.score = 1;
          this.barWidth = this.score * 25;
        }


      });
    } else {
      this.score = 0;
      this.barWidth = 0;
    }
  }

  get progressClass() {
    return "progress-bar-" + this.barWidth;
  }

  get scoreRanking() {
    return ["", "weak", "fair", "good", "strong"][this.score];
  }
}
