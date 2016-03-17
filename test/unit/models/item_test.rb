# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.



require 'test_helper'
class ItemTest < ActiveSupport::TestCase

	test 'cannot upload same file twice in same account' do 
		params = {}
	    params[:account_id] = accounts(:account1).id
	    params[:filename] = items(:item1).filename
	    item = Item.new(params)
	    assert_not item.valid?	
	end

	test 'can upload file to account' do 
		params = {}
		params[:account_id] = accounts(:account2).id
		params[:filename] = items(:item1).filename
		item = Item.new(params)
		assert item.valid?	

	end

end