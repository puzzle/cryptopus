# frozen_string_literal: true

class FolderMinimalSerializer < ApplicationSerializer
  attributes :id, :name, :description

  has_many :encryptables, serializer: EncryptableMinimalSerializer
end
