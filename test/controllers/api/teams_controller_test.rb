require 'test_helper'

class Api::TeamsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'returns teammember candidates for new team' do
    login_as(:admin)
    team = Team.create(users(:admin), {name: 'foo'})

    get :teammember_candidates, id: team

    candidates = JSON.parse(response.body)[1]

    assert_equal 2, candidates.size
    assert candidates.any? {|c| c['label'] == 'Alice test' }
    assert candidates.any? {|c| c['label'] == 'Bob test' }
  end
end
