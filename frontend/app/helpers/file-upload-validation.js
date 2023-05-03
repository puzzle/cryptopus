import { helper } from "@ember/component/helper";

const TenMB = 10000000;
export function fileUploadValidation(file) {
  if (file.size > TenMB) {
    let msg = this.intl.t("flashes.encryptable_files.uploaded_size_to_high");
    this.notify.error(msg);
    return false;
  } else if (file.size === 0) {
    let msg = this.intl.t("flashes.encryptable_files.uploaded_file_blank");
    this.notify.error(msg);
    return false;
  } else if (file.name === "") {
    let msg = this.intl.t(
      "flashes.encryptable_files.uploaded_filename_is_empty"
    );
    this.notify.error(msg);
    return false;
  } else {
    return true;
  }
}

export default helper(fileUploadValidation);
