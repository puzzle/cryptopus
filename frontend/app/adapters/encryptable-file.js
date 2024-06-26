import ApplicationAdapter from "./application";

export default class EncryptableFileAdapter extends ApplicationAdapter{
  pathForType() {
    return "encryptables";
  }
};
