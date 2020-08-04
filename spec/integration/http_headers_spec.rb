# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'HTTP headers' do
  include ControllerHelpers
  include IntegrationHelpers::DefaultHelper


  context 'Security' do
    it 'should return name of called api endpoint in content-disposition header' do
      login_as(:alice)
      get api_teams_path

      expect(response.status).to equal 200

      expect(response.headers['Content-Type']).to eq 'text/json'
      expect(response.headers['Content-Disposition']).to eq "attachment; filename='"\
      + api_teams_path + ".json'"
    end

    it 'should have met the same-site cookie attribute on login into the session' do
      post session_path, params: { username: 'alice', password: 'password' }

      expect(response.headers['Set-Cookie']).to include('SameSite=Lax')
    end
  end
end
