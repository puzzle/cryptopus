# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#  private     :boolean          default(FALSE), not null
#

require 'rails_helper'

describe TeamsController do
  include ControllerHelpers

  context 'GET index' do
    render_views

    it 'shows no delete button for teams to bob' do
      login_as(:bob)
      get :index
      expect(response.body).to_not match(/<a .* href="\/en\/teams\/#{teams(:team1).id}"/)
    end

    it 'shows delete button for teams to admin' do
      login_as(:admin)
      get :index
      expect(response.body).to match(/<a .* href="\/teams\/#{teams(:team1).id}"/)
    end

    it 'should redirect if pending recryptrequest' do
      Recryptrequest.create(user_id: users(:bob).id).save

      login_as(:bob)

      get :index

      expect(response).to redirect_to session_new_path
      expect(flash[:notice]).to match(/recryption of your team passwords/)
    end

    it 'redirects to login path if user has pending recryptrequests' do
      Recryptrequest.create(user_id: users(:bob).id)
      login_as(:bob)
      get :index
      expect(flash[:notice]).to match(/Wait for the recryption/)
    end
  end

end
