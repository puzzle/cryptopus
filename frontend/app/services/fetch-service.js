import Service from "@ember/service";
import ENV from "../config/environment";

export default class FetchService extends Service {
  headers = {
    "Content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    "X-CSRF-Token": ENV.CSRFToken
  };

  send(url, options) {
    options["headers"] = options["headers"] || this.headers;

    /* eslint-disable no-undef  */
    return fetch(url, options);
    /* eslint-enable no-undef  */
  }
}
