# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe 'Remove user' do
  include IntegrationHelpers::DefaultHelper
  it 'does not display remove button' do
    login_as('admin')
    get admin_users_path
    expect(response.body).to_not match(/a .* href="\/en\/admin\/users\/#{session[:user_id]}"/)
  end
end
