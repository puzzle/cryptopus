# frozen_string_literal: true

require 'spec_helper'

describe Api::ProfileController do
  include ControllerHelpers

  let(:bob) { users(:bob) }

  context 'PATCH update' do
    it 'updates bobs preferred_locale to german' do
      login_as(:bob)

      preferred_locale_params = {
        data: {
          attributes: {
            preferred_locale: 'de'
          }
        }
      }

      patch :update, params: preferred_locale_params, xhr: true

      expect(bob.preferred_locale).to eq('de')
    end
  end
end