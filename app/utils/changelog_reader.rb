# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

class ChangelogReader
  VERSION_REGEX = /^## [^\s]+ ((\d+\.)+(\d+))$/i
  ENTRY_REGEX = /^\*\s*(.*)/

  class << self
    def changelog
      ChangelogReader.new.changelogs
    end
  end

  attr_reader :changelogs

  def initialize
    @changelogs = []
    collect_changelog_data
  end

  private

  def collect_changelog_data
    changelog_file = File.read('CHANGELOG.md')
    parse_changelog_lines(changelog_file)
  end

  def parse_changelog_lines(changelog_file)
    changelog_file.each_line do |l|
      header_line = header_line(l)
      if header_line.present?
        add_version(header_line)
      else
        add_changelog_entry(entry_line(l))
      end
    end
  end

  def add_version(header_line)
    @current_version = ChangelogVersion.new(header_line)
    @changelogs << @current_version
  end

  def header_line(header_line)
    header_line.strip!
    header_line[VERSION_REGEX, 1]
  end

  def entry_line(entry_line)
    entry_line.strip!
    entry_line[ENTRY_REGEX, 1]
  end

  def add_changelog_entry(entry)
    return if entry.blank?

    @current_version.log_entries << entry
  end
end
