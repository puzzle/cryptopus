import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class LogoutTimerService extends Service {
  @tracked timeToLogoff;

  AUTOLOGOFF_TIME = 295
  /* eslint-disable no-undef  */
  logoutTimer = new Timer();
  /* eslint-enable no-undef  */

  reset() {
    if (this.logoutTimer.isRunning()){
      /* eslint-disable no-undef  */
      this.logoutTimer = new Timer();
      /* eslint-enable no-undef  */
    }
  }

  isRunning() {
    return this.logoutTimer.isRunning()
  }

  start() {
    this.reset()
    this.logoutTimer.start()

    this.logoutTimer.addEventListener('secondsUpdated', () => {
      let passedTime = this.logoutTimer.getTotalTimeValues().seconds
      if (passedTime === this.AUTOLOGOFF_TIME) {
        this.resetSession()
      } else {
        this.calculateTimeToLogoff(passedTime)
      }
    })
  }

  async resetSession() {
    /* eslint-disable no-undef  */
    await fetch(`/session/destroy/?autologout=true`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
      }
    });
    /* eslint-enable no-undef  */
    window.location.replace("/session/new");
  }

  calculateTimeToLogoff(passedTime){
      let remainingSeconds = this.AUTOLOGOFF_TIME - passedTime;
      let remainingMinutes = Math.floor(remainingSeconds / 60);
      let remainderSecondsOfMinutes = remainingSeconds % 60;

      this.timeToLogoff = remainingMinutes + "m " + remainderSecondsOfMinutes + "s";
  }
}
