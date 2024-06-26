import ApplicationAdapter from "./application";

export default class EncryptableCredentialAdapter extends ApplicationAdapter{
  pathForType() {
    return "encryptables";
  }
};
