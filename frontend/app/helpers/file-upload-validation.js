import { helper } from "@ember/component/helper";

const TenMB = 10000000;
export function fileUploadValidation(file, intl, notify) {
  if (file.size > TenMB) {
    let msg = intl.t("flashes.encryptable_files.uploaded_size_to_high");
    notify.error(msg);
    return false;
  } else if (file.size === 0) {
    let msg = intl.t("flashes.encryptable_files.uploaded_file_blank");
    notify.error(msg);
    return false;
  } else if (file.name === "") {
    let msg = intl.t("flashes.encryptable_files.uploaded_filename_is_empty");
    notify.error(msg);
    return false;
  } else {
    return true;
  }
}

export default helper(fileUploadValidation);
