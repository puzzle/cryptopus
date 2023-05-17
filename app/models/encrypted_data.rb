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

    if key == :custom_attr
      data_hash(iv, decode(value[:data]), value[:label])
    else
      data_hash(iv, decode(value[:data]))
    end
  end

  def []=(key, data:, iv:, label: nil)
    @data[key] = data_hash(encode(iv), encode(data), label)
  end

  def to_json(*_args)
    @data.reject { |_, value| value[:data].blank? }.to_json
  end

  private

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
