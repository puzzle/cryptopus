# frozen_string_literal: true

class Encryptable::FileSerializer < EncryptableSerializer
  attributes :id, :name, :description, :sender_name, :created_at

  belongs_to :encryptable_credential, if: -> { object.encryptable_credential.present? }
end
