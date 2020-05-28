import Service from '@ember/service';

export default class PasswordScoreService extends Service {
  strengthNumber;
  async score(password, passwordStrength) {
    await passwordStrength.strength(password).then(strength => {
      this.strengthNumber = strength.score
    })
  }
};
