import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class LogoutTimerService extends Service {
  @tracked timeToLogoff;

  AUTOLOGOFF_TIME = 5;

  countDownDate;

  timerInterval;

  reset() {
    if (this.timerInterval) {
      /* eslint-disable no-undef  */
      clearInterval(this.timerInterval);
      /* eslint-enable no-undef  */
    }
  }

  isRunning() {
    return !!this.timerInterval;
  }

  start() {
    this.reset();
    this.countDownDate = new Date().getTime();

    this.timerInterval = setInterval(() => {
      let now = new Date().getTime();

      let passedTime = now - this.countDownDate;

      let passedTimeInSeconds = Math.floor(passedTime / 1000);

      if (passedTimeInSeconds >= this.AUTOLOGOFF_TIME) {
        this.resetSession();
      } else {
        this.calculateTimeToLogoff(passedTimeInSeconds);
      }
    }, 1000);
  }

  resetSession() {
    sessionStorage.setItem("previousPath", window.location.pathname);
    window.location.replace("/session/destroy?autologout=true");
  }

  calculateTimeToLogoff(passedTime) {
    let remainingSeconds = this.AUTOLOGOFF_TIME - passedTime;
    let remainingMinutes = Math.floor(remainingSeconds / 60);
    let remainderSecondsOfMinutes = remainingSeconds % 60;

    this.timeToLogoff =
      remainingMinutes + "m " + remainderSecondsOfMinutes + "s";
  }
}
