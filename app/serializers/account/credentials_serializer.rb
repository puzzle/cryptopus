# frozen_string_literal: true

class Account::CredentialsSerializer < AccountSerializer
  attributes :cleartext_username, :cleartext_password, :created_at, :updated_at
end
