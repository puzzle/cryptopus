#  encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
describe ChangelogReader do

  describe 'verify CHANGELOG.md' do

    it 'Every changelog entry has a version' do
      ChangelogReader.changelog.each do |changelog_entry|
        version = changelog_entry.version
        assert(true, version.nil?)
      end
    end

    it 'Every changlog entry has at least one entry' do
      ChangelogReader.changelog.each do |changelog_entry|
        assert(true, changelog_entry.log_entries.nil?)
      end
    end
  end

  describe 'test ChangelogReader' do

    subject { ChangelogReader.new }

    let(:changelog_lines) do
      [
        'foo',  #Invalid line
        '## Version 1.3',
        'fee', #Invalid line
        '* change',
        '* another change',
        '## Version 1.1',
        '* changes'
      ].join("\n")
    end

    before do
      subject.instance_variable_set(:@changelogs, [])
    end

    it 'reads log correctly' do
      subject.send(:parse_changelog_lines, changelog_lines)

      changelogs = subject.instance_variable_get(:@changelogs)

      assert_equal(2, changelogs.count)

      version13 = changelogs[0]
      assert_equal(2, version13.log_entries.count)
      assert_equal('1.3', version13.version)
      assert_equal('change', version13.log_entries[0])
      assert_equal('another change', version13.log_entries[1])

      version11 = changelogs[1]
      assert_equal(1, version11.log_entries.count)
      assert_equal('1.1', version11.version)
      assert_equal('changes', version11.log_entries[0])
    end

    it 'header line parsed' do
      version = subject.send(:header_line, '## Version 0.0')
      assert_equal('0.0', version)
    end

    it 'entry line parsed' do
      entry = subject.send(:entry_line, '* change')
      assert_equal('change', entry)
    end

    it 'doesnt parse invalid line' do
      version = subject.send(:header_line, 'invalid')
      assert_nil(version)

      entry = subject.send(:entry_line, 'invalid')
      assert_nil(entry)
    end
  end
end
