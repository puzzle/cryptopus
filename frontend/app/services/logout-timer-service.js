import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class LogoutTimerService extends Service {
  @tracked timeToLogoff;

  AUTOLOGOFF_TIME = 8

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
    this.reset()
    this.logoutTimer.start()

    this.logoutTimer.addEventListener('secondsUpdated', e => {
      let passedTime = this.logoutTimer.getTotalTimeValues().seconds
      if (passedTime === this.AUTOLOGOFF_TIME) {
        this.resetSession()
      } else {
        this.calculateTimeToLogoff(passedTime)
      }
    })
  }

  resetSession() {
    /* eslint-disable no-undef  */
    fetch(`/session`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
      }
    }).then(console.log('Session deleted'));
    /* eslint-enable no-undef  */
  }

  calculateTimeToLogoff(passedTime){
      let remainingSeconds = this.AUTOLOGOFF_TIME - passedTime;
      let remainingMinutes = Math.floor(remainingSeconds / 60);
      let remainderSecondsOfMinutes = remainingSeconds % 60;

      this.timeToLogoff = remainingMinutes + "m " + remainderSecondsOfMinutes + "s";
  }
}
