# frozen_string_literal: true

class Account::OSESecretSerializer < AccountSerializer
  attributes :cleartext_ose_secret
end
