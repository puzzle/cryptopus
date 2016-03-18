require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper


	test 'Cannot upload file with empty filename'  do
		login_as(:bob)
		file = fixture_file_upload('files/emptyfile/ ','text/plain')
		item_params = {filename: 'Testfile', content_typ: 'application/zip', file: file, description: 'test' }
	    post :create, team_id: teams(:team1), group_id: groups(:group1), account_id: accounts(:account1), item: item_params
		assert_match /The file has to be named/, flash[:error]
	end

	test 'Cannot upload nothing'  do
	    login_as(:bob)
		item_params = {}
	    post :create, team_id: teams(:team1), group_id: groups(:group1), account_id: accounts(:account1), item: item_params
	    assert_match /No file was uploaded/, flash[:error]
	end


end
