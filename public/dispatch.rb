# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

# !/usr/bin/ruby

require File.dirname(__FILE__) + '/../config/environment' unless defined?(RAILS_ROOT)

# If you're using RubyGems and mod_ruby, this require
# should be changed to an absolute path one, like:
# "/usr/local/lib/ruby/gems/1.8/gems/rails-0.8.0/lib/dispatcher"
# -- otherwise performance is severely impaired
require 'dispatcher'

if defined?(Apache::RubyRun)
  ADDITIONAL_LOAD_PATHS.reverse_each do |dir|
    $LOAD_PATH.unshift(dir) if File.directory?(dir)
  end
end

Dispatcher.dispatch
