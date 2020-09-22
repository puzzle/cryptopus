# frozen_string_literal: true

class Account::EncryptedData
  include JsonSerializable

  attr_accessor :data, :iv

  def initialize(data: nil, iv: nil)
    @data = data
    @iv = iv
  end
end
