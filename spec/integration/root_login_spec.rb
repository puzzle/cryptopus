# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'Root login' do
  include IntegrationHelpers::DefaultHelper
  context 'Db as provider' do
    it 'lets root login via local ip' do
      post session_root_path, params: { username: 'root', password: 'password' }
      follow_redirect!
      expect(request.fullpath).to eq(search_path)
      expect(response.body).to match(/Hi  Root! Want to recover a password?/)
    end

    it 'does not let root login via external ip' do
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:root_ip_authorized?)
        .and_return(false)
      post session_root_path, params: { username: 'root', password: 'password' }
      follow_redirect!
      follow_redirect!
      expect(request.fullpath).to eq(session_new_path)
      expect(response.body).to match(/Login as root only from private IP accessible/)
    end
  end

  context 'Ldap as provider' do
    it 'lets root login via local ip' do
      enable_ldap
      post session_root_path, params: { username: 'root', password: 'password' }
      follow_redirect!
      expect(request.fullpath).to eq(search_path)
      expect(response.body).to match(/Hi  Root! Want to recover a password?/)
    end

    it 'does not let root login via external ip' do
      enable_ldap
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:root_ip_authorized?)
        .and_return(false)
      post session_root_path, params: { username: 'root', password: 'password' }
      follow_redirect!
      follow_redirect!
      expect(request.fullpath).to eq(session_new_path)
      expect(response.body).to match(/Login as root only from private IP accessible/)
    end
  end
  context 'Keycloak as provider' do
    it 'lets root login via local ip' do
      enable_keycloak
      post session_root_path, params: { username: 'root', password: 'password' }
      follow_redirect!
      expect(request.fullpath).to eq(search_path)
      expect(response.body).to match(/Hi  Root! Want to recover a password?/)
    end

    it 'does not let root login via external ip' do
      enable_keycloak
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:root_ip_authorized?)
        .and_return(false)
      expect(Keycloak::Client).to receive(:url_login_redirect).and_return(session_sso_path)
      post session_root_path, params: { username: 'root', password: 'password' }
      follow_redirect!
      expect(request.fullpath).to eq(teams_path)
      expect(response).to redirect_to session_sso_path
    end
  end
end
