import { inject as service } from "@ember/service";
import ApplicationController from "../application";

export default class TeamsIndexController extends ApplicationController {
  @service loading;
}
