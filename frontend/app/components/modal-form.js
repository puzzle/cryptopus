import { bind } from "@ember/runloop";
import BaseFormComponent from "./base-form-component";

export default class ModalForm extends BaseFormComponent {

  setupModal(element, args) {
    var context = args[0];
    context.modalElement = element;
    /* eslint-disable no-undef  */
    $(element).on("hidden.bs.modal", bind(context, context.abort));
    $(element).modal("show");
    $('[data-toggle="private-info-tooltip"]').tooltip();
    /* eslint-enable no-undef  */
  }

}
