# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class ItemTest < ActiveSupport::TestCase

	test 'does not upload same file twice in same account' do
		params = {}
    params[:account_id] = accounts(:account1).id
    params[:file] = items(:item1).file
    params[:filename] = items(:item1).filename
    item = Item.new(params)
    assert_not item.valid?
    assert_equal item.errors.messages[:filename].first, "Filename is already taken"
	end

	test 'can upload file to account' do
		params = {}
		params[:account_id] = accounts(:account2).id
		params[:filename] = items(:item1).filename
    params[:file] = items(:item1).file
		item = Item.new(params)
		assert item.valid?
	end

  test 'decrypts item' do
    bob = users(:bob)
    bobs_private_key = bob.decrypt_private_key('password')
    account = accounts(:account1)
    team = account.group.team
    cleartext_team_password = team.decrypt_team_password(bob, bobs_private_key)
    item = account.items.first
    assert_equal "Das ist ein test File", item.decrypt(cleartext_team_password) 
  end

  test 'encrypt item' do 
    bob = users(:bob)
    bobs_private_key = bob.decrypt_private_key('password')
    account = accounts(:account1)
    team = account.group.team
    cleartext_team_password = team.decrypt_team_password(bob, bobs_private_key)
    item = Item.new(account_id: account.id, cleartext_file: "Das ist ein test File", filename: "test", content_type: "text")
    item.encrypt(cleartext_team_password)
    item.save!
    item = Item.find(item.id)

    assert_nil item.cleartext_file
    item.decrypt(cleartext_team_password)
    assert_equal "Das ist ein test File", item.cleartext_file
  end
end
