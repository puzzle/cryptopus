# frozen_string_literal: true

class EncryptedData
  include JsonSerializable

  def initialize(data = nil)
    @data = data.presence || {}
  end

  def [](key)
    return nil unless @data.key?(key)

    value = @data[key]
    iv = decode(value[:iv]) unless value[:iv].nil?

    data_hash(iv, decode(value[:data]))
  end

  def []=(key, data:, iv:)
    @data[key] = data_hash(encode(iv), encode(data))
  end

  def to_json(*_args)
    @data.reject { |_, value| value[:data].blank? }.to_json
  end

  private

  def data_hash(iv, data)
    { iv: iv, data: data }
  end

  def encode(value)
    Base64.strict_encode64(value) unless value.nil?
  end

  def decode(value)
    Base64.decode64(value)
  end
end
