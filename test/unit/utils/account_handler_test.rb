# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountHandlerTest < ActiveSupport::TestCase

   
  test 'Move account from one group to a group from another team' do
     account = accounts(:account2)
     bob = users(:bob)
     private_key = decrypt_private_key(bob)
     new_group = groups(:group1)
     
     assert_equal account.group_id, groups(:group2).id

     account_handler = AccountHandler.new(account)
     account_handler.move(new_group, private_key, bob)
     account.reload

     assert_equal account.group_id, new_group.id
   end
  
  test 'Move account with items to new team' do
     account = accounts(:account1)
     bob = users(:bob)
     private_key = decrypt_private_key(bob)
     new_group = groups(:group2)
     new_team_password = new_group.team.decrypt_team_password(bob, private_key)

     account_handler = AccountHandler.new(account)
     account_handler.move(new_group, private_key, bob)
     
     decrypt_file_item1 = items(:item1).decrypt_file(items(:item1).file, new_team_password)
     decrypt_file_item2 = items(:item2).decrypt_file(items(:item2).file, new_team_password)
     
     assert_equal "Das ist ein test File", decrypt_file_item1
     assert_equal "Das ist ein test File", decrypt_file_item2
     assert_equal items(:item2).account, account
     assert_equal items(:item2).account.group.team, teams(:team2)
   end

  test 'Alice want to move an account to a team shes not member of' do
    alice = users(:alice)
    private_key = decrypt_private_key(alice)
    account = accounts(:account1)
    new_group = groups(:group2)
    
    assert_raise "You don't have the permisson to the Team" do
     account_handler = AccountHandler.new(account)
     account_handler.move(new_group, private_key, alice)
    end
  end

end
