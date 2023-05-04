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
      data_hash_label(iv, value[:label],decode(value[:data]))
    else
      data_hash(iv, decode(value[:data]))
    end
  end

  def []=(key, label: nil , data:, iv:)
    if label.present?
      @data[key] = data_hash_label(encode(iv), label, encode(data))
    else
      @data[key] = data_hash(encode(iv), encode(data))
    end
  end

  def to_json(*_args)
    @data.reject { |_, value| value[:data].blank? }.to_json
  end

  private

  def data_hash(iv, data)
    { iv: iv, data: data }
  end

  def data_hash_label(iv, label, data)
    { iv: iv, label: label, data: data }
  end

  def encode(value)
    Base64.strict_encode64(value) unless value.nil?
  end

  def decode(value)
    Base64.decode64(value)
  end
end
