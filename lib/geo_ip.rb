# frozen_string_literal: true

class GeoIp

  MAX_MIND_DB_PATH = Rails.root.join('db/geo_ip.mmdb').freeze

  def initialize
    @max_mind = MaxMind::DB.new(MAX_MIND_DB_PATH)
  end

  def country_code(ip_address)
    @max_mind.get(ip_address).
      try(:[], 'country').
      try(:[], 'iso_code')
  end

  class << self
    def activated?
      if country_whitelist_configured?
        db_present? ? true : (raise error_message)
      else
        db_present?
      end
    end

    private

    def db_present?
      File.exist?(MAX_MIND_DB_PATH)
    end

    def country_whitelist_configured?
      Setting.value(:general, :country_source_whitelist).present?
    end

    def error_message
      'Either remove all countrys from the settings or install geo ip db (https://github.com/puzzle/cryptopus/wiki/Geo-IP-Database).'
    end
  end
end
