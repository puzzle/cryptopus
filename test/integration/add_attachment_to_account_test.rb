# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AddAttachmentToAccountTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper
  test 'add and remove attachment to account2' do
    team = teams(:team1)
    group = groups(:group1)
    account = accounts(:account2)

    login_as('bob')
    items_path = team_group_account_items_path team, group, account
    file_path = 'test/fixtures/files/test_file.txt'
    post items_path, item: {file: fixture_file_upload(file_path, 'text/plain')}
    logout

    login_as('alice')
    file = account.items.first
    item_path = team_group_account_item_path team, group, account, file
    get item_path
    assert_equal 'certificate', response.body
    assert_equal 'text/plain', response.header['Content-Type']
    assert_includes response.header['Content-Disposition'], 'test_file.txt'
    delete item_path
    logout

    login_as('bob')
    error = assert_raises(ActiveRecord::RecordNotFound) { get item_path }
    assert_includes error.message, "Couldn't find Item"
  end
end