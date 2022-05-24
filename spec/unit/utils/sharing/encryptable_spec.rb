# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../app/utils/sharing/encryptable'

describe Encryptable::Sharing do

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }


  it 'share encryptable with other user' do
    login_as(:alice)

  end
end
