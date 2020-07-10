import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class LogoutTimerService extends Service {
  @tracked timeToLogoff;

  AUTOLOGOFF_TIME = 298

  logoutTimer = new Timer();

  reset() {
    if (this.logoutTimer.isRunning()){
      this.logoutTimer = new Timer();
    }
  }

  isRunning() {
    return this.logoutTimer.isRunning()
  }

  start() {
    this.logoutTimer.start()

    this.logoutTimer.addEventListener('secondsUpdated', e => {
      let passedTime = this.logoutTimer.getTotalTimeValues().seconds
      this.calculateTimeToLogoff(passedTime)
    })
  }

  redirectToNewSession() {
    window.location.replace('/session/new');
  }

  calculateTimeToLogoff(passedTime){
    if (passedTime === this.AUTOLOGOFF_TIME) {
      this.redirectToNewSession()
    } else {
      let remainingSeconds = this.AUTOLOGOFF_TIME - passedTime;
      let remainingMinutes = Math.floor(remainingSeconds / 60);
      let remainderSecondsOfMinutes = remainingSeconds % 60;

      this.timeToLogoff = remainingMinutes + "m " + remainderSecondsOfMinutes + "s";
    }
  }
}
