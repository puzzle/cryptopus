# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class ItemTest < ActiveSupport::TestCase


test 'cannot upload a file twice in same account' do
    params = {}
    params[:filename] = 'password'
    params[:account_id] = accounts(:account1).id
    params[:created_at] = DateTime.now
    params[:updated_at] = DateTime.now
    params[:content_type] = 'image/jpeg'


    item1 = Item.create(params)
    item2 = Item.new(params)
    assert_not item2.valid?
    assert_equal [:filename], item2.errors.keys
end

test 'upload a file twice' do
    params = {}
    params[:filename] = 'password'
    params[:account_id] = accounts(:account1).id
    params[:updated_at] = DateTime.now
    params[:content_type] = 'image/jpeg'

    params2 = {}
    params2[:filename] = 'password'
    params2[:account_id] = accounts(:account2).id
    params2[:updated_at] = DateTime.now
    params2[:content_type] = 'image/jpeg'

    item1 = Item.create(params)
    item2 = Item.create(params2)
 	assert item1.valid?
 	assert item2.valid?

end


end