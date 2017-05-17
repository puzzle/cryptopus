# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'zlib'
require 'net/http'

GEO_DAT_URL='https://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz'.freeze

namespace :geo do
  desc 'downloads geo ip dat file from maxmind'
  task :fetch do
    
    uri = URI(GEO_DAT_URL)
    ip_geo_dat_gz = Net::HTTP.get(uri)
    ip_geo_dat = Zlib::GzipReader.new(StringIO.new(ip_geo_dat_gz)).read
    Rails.root.join('db', 'GeoIP.dat').write(ip_geo_dat)

  end

end
