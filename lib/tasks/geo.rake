# encoding: utf-8

#  Copyright (c) 2008-2019, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

namespace :geo do
  desc 'downloads ip country db file from maxmind'
  task :fetch do
    script = Rails.root.join('bin', 'fetch_geo_ip_db')
    %x( #{script} #{Rails.root.to_s})
  end
end
