# encoding: utf-8
# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null
#


#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'does not upload file with empty filename'  do
    account1 = accounts(:account1)

    login_as(:bob)
    file = fixture_file_upload('files/emptyfile/ ','text/plain')
    item_params = {filename: 'Testfile', content_typ: 'application/zip', file: file, description: 'test' }

    assert_difference('Item.count', 0) do
      post :create, params: { team_id: teams(:team1), group_id: groups(:group1), account_id: account1, item: item_params }
    end
  end

  test 'Doesnt upload if no file and no item  params exist'  do
    login_as(:bob)
    item_params = {}

    assert_difference('Item.count', 0) do
      assert_raise ActionController::ParameterMissing do
        post :create, params: { team_id: teams(:team1), group_id: groups(:group1), account_id: accounts(:account1), item: item_params }
      end
    end
  end
end
