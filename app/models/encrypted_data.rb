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

    data_hash(iv, decode(value[:data]), value[:label])
  end

  def []=(key, data:, iv:, label: nil)
    @data[key] = data_hash(encode(iv), encode(data), label)
  end

  def to_json(*_args)
    present_data.to_json
  end

  def used_attributes
    present_data.keys
  end

  private

  def present_data
    @data.reject { |_, value| value[:data].blank? }
  end

  def data_hash(iv, data, label = nil)
    hash = { iv: iv, data: data }
    hash[:label] = label if label
    hash
  end

  def encode(value)
    Base64.strict_encode64(value) unless value.nil?
  end

  def decode(value)
    Base64.decode64(value)
  end
end
