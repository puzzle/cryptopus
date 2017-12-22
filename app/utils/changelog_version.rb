# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

class ChangelogVersion
  attr_accessor :major_version, :minor_version, :log_entries, :version

  def initialize(header_line)
    values         = header_line.split('.')
    @version       = header_line
    @major_version = values.first.to_i
    @minor_version = values.second.to_i
    @log_entries   = []
  end

  def label
    "Version #{version}"
  end
end
