# encoding: utf-8

#  Copyright (c) 2008-2019, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rubygems/package'
require 'zlib'
require 'net/http'

GEO_IP_DATA_URL='https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz'.freeze

namespace :geo do
  desc 'downloads ip country mmdb file from maxmind'
  task :fetch do
    
    uri = URI(GEO_IP_DATA_URL)
    geo_ip_gz = Net::HTTP.get(uri)
    geo_ip_tar = Zlib::GzipReader.new(StringIO.new(geo_ip_gz)).read
    tar_extract = Gem::Package::TarReader.new(StringIO.new(geo_ip_tar))
    tar_extract.rewind # The extract has to be rewinded after every iteration
    tar_extract.each do |entry|
      file_name = entry.full_name
      if file_name.include?('GeoLite2-Country.mmdb')
        entry.rewind
        Rails.root.join('db', 'geo_ip.mmdb').write(entry.read, encoding: 'ascii-8bit')
      end
      tar_extract.close
    end
  end
end
