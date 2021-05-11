# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe ChangelogReader do

  context 'verify CHANGELOG.md' do
    it 'verifies every changelog entry has a version' do
      ChangelogReader.changelog.each do |changelog_entry|
        version = changelog_entry.version
        expect(version).to_not be_nil
      end
    end

    it 'verifies every changlog entry has at least one entry' do
      ChangelogReader.changelog.each do |changelog_entry|
        expect(changelog_entry.log_entries).to_not be_nil
      end
    end
  end

  context 'test ChangelogReader' do

    let(:changelog_reader) { ChangelogReader.new }

    let(:changelog_lines) do
      [
        'foo', # Invalid line
        '## Version 1.3',
        'fee', # Invalid line
        '- change',
        '- another change',
        '## Version 1.1',
        '- changes'
      ].join("\n")
    end

    before(:each) do
      changelog_reader.instance_variable_set(:@changelogs, [])
    end

    it 'reads log correctly' do
      changelog_reader.send(:parse_changelog_lines, changelog_lines)

      changelogs = changelog_reader.instance_variable_get(:@changelogs)

      expect(changelogs.count).to eq(2)

      version13 = changelogs[0]
      expect(version13.log_entries.count).to eq(2)
      expect(version13.version).to eq('1.3')
      expect(version13.log_entries[0]).to eq('change')
      expect(version13.log_entries[1]).to eq('another change')

      version11 = changelogs[1]
      expect(version11.log_entries.count).to eq(1)
      expect(version11.version).to eq('1.1')
      expect(version11.log_entries[0]).to eq('changes')
    end

    it 'parses header line' do
      version = changelog_reader.send(:header_line, +'## Version 0.0')
      expect(version).to eq('0.0')
    end

    it 'parses entry line' do
      entry = changelog_reader.send(:entry_line, +'- change')
      expect(entry).to eq('change')
    end

    it 'doesnt parse invalid line' do
      version = changelog_reader.send(:header_line, +'invalid')
      expect(version).to be_nil

      entry = changelog_reader.send(:entry_line, +'invalid')
      expect(entry).to be_nil
    end
  end
end
