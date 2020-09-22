# frozen_string_literal: true

class Account::Data
  include JsonSerializable
  attr_accessor :ose_secret

  def initialize(ose_secret: '')
    @ose_secret = ose_secret
  end
end
