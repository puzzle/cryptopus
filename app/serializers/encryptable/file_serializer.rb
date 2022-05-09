# frozen_string_literal: true

class Encryptable::FileSerializer < ApplicationSerializer
  attributes :id, :name, :description

  belongs_to :encryptable_credential
end
