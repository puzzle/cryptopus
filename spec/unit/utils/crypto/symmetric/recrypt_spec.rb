# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/aes256iv'

describe Crypto::Symmetric::Recrypt do
  let(:team1) { teams(:team1) }
  let(:team2) { teams(:team2) }

  it 'recrypts given team' do

  end

  it 'doesnt recrypt team if default algorithm already used' do
    Crypto::Symmetric::Recrypt.update(team1)

  end

  it 'aborts in transaction if error suddenly appears' do

  end

end
