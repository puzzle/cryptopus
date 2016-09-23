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

     account_handler = AccountHandler.new(account)
     account_handler.move(new_group, private_key, bob.id)
     account.reload

     assert_equal account.group_id, new_group.id
   end
  
  test 'Move account with items to new team' do
     account = accounts(:account1)
     bob = users(:bob)
     private_key = decrypt_private_key(bob)
     new_group = groups(:group2)
     account.cleartext_password = ""
     
     account_handler = AccountHandler.new(account)
     account_handler.move(new_group, private_key, bob.id)
      
     assert_equal items(:item1).account, account
     assert_equal items(:item1).account.group.team, teams(:team2)
     assert_equal items(:item2).account, account
     assert_equal items(:item2).account.group.team, teams(:team2)
   end

  test 'Alice want to move an account to a team shes not member of' do
    alice = users(:alice)
    private_key = decrypt_private_key(alice)
    account = accounts(:account1)
    new_group = groups(:group2)
    
    assert_raise NoMethodError do
     account_handler = AccountHandler.new(account)
     account_handler.move(new_group, private_key, alice.id)
    end
  end


end
