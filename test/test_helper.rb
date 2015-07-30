ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/autorun"
Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |f| require f }


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
    def login_as(username, password = 'password')
      post_via_redirect "/login/authenticate", username: username, password: password
    end

    def logout
      get '/login/logout'
    end

    def get_account_path
      team = teams(:team1)
      group = groups(:group1)
      account = accounts(:account1)
      team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    end
end
