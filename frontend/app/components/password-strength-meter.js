import { inject as service } from "@ember/service";
import { isPresent, isNone } from "@ember/utils";
import Component from "@ember/component";
import { tracked } from "@glimmer/tracking";

export default class PasswordStrengthMeterComponent extends Component {
  @service('password-score') passwordScore;
  @service passwordStrength;
  @service intl;

  @tracked password;
  @tracked passwordElement;

  COLORS = ['#fc0303', '#fc6703', '#fcc603', '#4dd100']
  TRANSLATIONS = ['commonPassword', 'veryBadPassword', 'badPassword', 'goodPassword', 'veryGoodPassword']

  init() {
    super.init(...arguments);
    this.passwordStrength.load()

    this.addObserver('passwordElement', this, 'updatePasswordScore');
    this.addObserver('password', this, 'updatePasswordScore');
  }

  updatePasswordScore() {
    if (isPresent(this.password) && isPresent(this.passwordElement)) {
      this.passwordScore.score(this.password, this.passwordStrength).then(() => {
        this.renderPopover(this.popoverContent(this.passwordScore.strengthNumber), this.popoverTemplate());
        if (!$(this.passwordElement).next('div.popover:visible').length){
          $(this.passwordElement).popover('show')
        }
        console.log(this.passwordScore.strengthNumber)
        console.log(this.password)
        console.log(this.passwordElement)

        $(this.passwordElement).next(".popover").find(".popover-content").html(this.popoverContent(this.passwordScore.strengthNumber));
        $(this.passwordElement).next(".popover").find(".popover-template").html(this.popoverTemplate());
      })
    }
  }

  popoverContent(passwordScore) {
    let calculatedScore = passwordScore * 25;
    let translation = this.intl.t(this.TRANSLATIONS[passwordScore])
    let color = passwordScore === 0 ? "none" : this.COLORS[passwordScore - 1]
    return '<div class="progress">' +
      '<div class="progress-bar" role="progressbar" style="width: ' + calculatedScore + '%; background-color: ' + color + ' !important;" aria-valuenow="' + calculatedScore + '" aria-valuemin="0" aria-valuemax="100"></div>' +
      '</div>' + '<p class="font-weight-bold">' + translation + '</p>';
  }

  popoverTemplate() {
    return '<div class="popover"><div class="arrow"></div>'+
      '<h3 class="popover-title"></h3><div class="popover-content"></div></div>';
  }


  renderPopover(content, template) {
    $(this.passwordElement).popover({
      trigger: 'focus',
      placement: 'top',
      title: this.intl.t('passwordStrength'),
      html: 'true',
      content : content,
      template: template
    });
  }
};


