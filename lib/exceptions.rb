module Exceptions
  class UserDoesNotExist < StandardError; end
  class UserCreationFailed < StandardError; end
  class AuthenticationFailed < StandardError; end
  class DecryptFailed < StandardError; end
  class UnknownAuthenticationMethod < StandardError; end
end

