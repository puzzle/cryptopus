import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import ApplicationController from "../application";

export default class TeamsIndexController extends ApplicationController {
  @service loading;
}
