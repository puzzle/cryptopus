module.exports = function (environment) {
  return {
    delivery: ['meta'],
    policy: {
      // Deny everything by default
      'default-src': ["'none'"],
      // Allow scripts at https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js
      'script-src': ["'self'", 'https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js'],
      // Allow fonts to be loaded
      'font-src': ["'self'"],
      // Allow data (xhr/websocket) from api-js.mixpanel.com and custom-api.local
      'connect-src': ["'self'", 'https://api-js.mixpanel.com', 'https://custom-api.local'],
      // Allow images from the origin itself (i.e. current domain)
      'img-src': ["'self'"],
      // Allow CSS loaded from https://fonts.googleapis.com
      'style-src': ["'self'", 'https://fonts.googleapis.com'],
      // Omit `media-src` from policy
      // Browser will fallback to default-src for media resources (which is 'none', see above)
      'media-src': null
    },
    reportOnly: false
  };
};
