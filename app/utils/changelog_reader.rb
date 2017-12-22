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
    changelog_file = read_changelog
    parse_changelog(changelog_file)
  end

  def read_changelog
    File.exist?('CHANGELOG.md') ? File.read('CHANGELOG.md') : ''
  end

  def parse_changelog(file)
    log_entry = nil
    file.each_line do |line|
      header_line = header_line(line)
      entry_line = entry_line(line)
      log_entry = evaluate_current_line(log_entry, header_line, entry_line)
    end
    @changelogs << log_entry
  end

  def evaluate_current_line(log_entry, header_line, entry_line)
    if log_entry.nil?
      header_line.present? ? log_entry = ChangelogEntry.new(header_line) : log_entry
    elsif header_line.present?
      log_entry = add_and_get_new_entry(log_entry, header_line)
    elsif entry_line.present?
      log_entry.add(entry_line)
    end
    log_entry
  end

  def add_and_get_new_entry(log_entry, header_line)
    changelogs << log_entry
    ChangelogEntry.new(header_line)
  end

  def header_line(header_line)
    header_line.strip!
    header_line[VERSION_REGEX, 1]
  end

  def entry_line(entry_line)
    entry_line.strip!
    entry_line[ENTRY_REGEX, 1]
  end
end
