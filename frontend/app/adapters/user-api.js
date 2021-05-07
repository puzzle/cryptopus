import ApplicationAdapter from "./application";

export default class ApiUserAdapter extends ApplicationAdapter {
  pathForType() {
    return "api_users";
  }
}
