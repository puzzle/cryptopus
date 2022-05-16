# frozen_string_literal: true

class FolderMinimalSerializer < ApplicationSerializer
  attributes :id, :name, :description

  has_many :encryptables, serializer: EncryptableMinimalSerializer

  def encryptables
    object.encryptables.reject do |encryptable|
      encryptable.type == Encryptable::File.sti_name
    end
  end
end
