import Service from '@ember/service';

export default class ScreenWidthService extends Service {

  get isShownOnHamburgermenu() {
    return window.screen.width < 991;
  }
}
