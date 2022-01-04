# frozen_string_literal: true

#  Copyright (c) 2008-2022, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

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

  def to_json
    @data.reject{ |_, value| value[:data].blank? }.to_json
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