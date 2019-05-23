# frozen_string_literal: true

class GeoIp

  MAX_MIND_DB_PATH = Rails.root.join('db', 'geo_ip.mmdb').freeze

  def initialize
    unless File.exist?(MAX_MIND_DB_PATH)
      raise 'geo ip db file missing: please run rake geo:fetch'
    end

    @max_mind = MaxMind::DB.new(MAX_MIND_DB_PATH)
  end

  def country_code(ip_address)
    @max_mind.get(ip_address).
      try(:[], 'country').
      try(:[], 'iso_code')
  end

end
