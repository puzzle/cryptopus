class User::Api::Options
  attr_accessor :valid_until, :source_ips, :encrypted_token, :description
  attr_reader :valid_for

  def valid_for=(value)
    @valid_for = value.to_i
  end
end
