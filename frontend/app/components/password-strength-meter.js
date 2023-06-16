import Component from "@ember/component";
import { tracked } from "@glimmer/tracking";
import { isPresent } from "@ember/utils";
import zxcvbn from "zxcvbn";

export default class PasswordStrengthMeterComponent extends Component {
  @tracked barWidth = 0;
  @tracked score = 0;

  constructor() {
    super(...arguments);
  }

  get passwordStrengthScore() {
    const { score } = zxcvbn(this.password);

    return score;
  }

  didReceiveAttrs() {
    super.didReceiveAttrs();
    if (isPresent(this.password) && this.password !== "") {
      this.score = this.passwordStrengthScore;
      if (this.score === 0) this.score = 1;
      this.barWidth = this.score * 25;
    } else {
      this.score = 0;
      this.barWidth = 0;
    }
  }

  get progressClass() {
    return "progress-bar-" + this.barWidth;
  }

  get scoreRanking() {
    return ["none", "weak", "fair", "good", "strong"][this.score];
  }
}
