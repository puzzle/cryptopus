import * as Sentry from '@sentry/browser'
import * as Integrations from '@sentry/integrations';
import ENV from "../config/environment";
import { isPresent } from '@ember/utils';

export function initialize() {
  if (ENV.environment === "production" && isPresent(ENV.sentryDsn)) {
    Sentry.init({
      dsn: ENV.sentryDsn,
      integrations: [new Integrations.Ember()]
    });
  }
}

export default {
  after: ['env-settings'],
  initialize
};
