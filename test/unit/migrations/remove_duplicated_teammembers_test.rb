# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
migration_file_name = Dir[Rails.root.join('db/migrate/20160823115543_remove_duplicated_teammembers.rb')].first
require migration_file_name

class RemoveDuplicatedTeammembersTest < ActiveSupport::TestCase

  before(:each) do
    Teammember.delete_all
  end

  describe '#up' do
    test 'delete duplicated teammember' do
      teammembers = [{ tid: 1, uid: 1, pw: 'pw' },
                     { tid: 1, uid: 1, pw: 'pw1'},
                     { tid: 2, uid: 2, pw: 'pw2'}]
      
      create_teammembers(teammembers)
      
      migration.up

      assert_equal 2, Teammember.all.count
    end

    test 'does not delete any teammember' do
      teammembers = [{ tid: 1, uid: 1, pw: 'pw' },
                     { tid: 2, uid: 2, pw: 'pw2'},
                     { tid: 3, uid: 3, pw: 'pw3'}]
     
      create_teammembers(teammembers)

      migration.up

      assert_equal 3, Teammember.all.count
    end
  end

  private

  def create_teammembers(teammembers)
    teammembers.each do |tm|
      Teammember.create!(team_id: tm[:tid],
                         user_id: tm[:uid],
                         password: tm[:pw])
    end
  end

  def migration
    RemoveDuplicatedTeammembers.new
  end

end
