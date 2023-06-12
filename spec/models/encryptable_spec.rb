# frozen_string_literal: true

require 'spec_helper'

describe Encryptable do

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:encryptable) { encryptables(:credentials1) }
  let(:team) { teams(:team1) }

  it 'does not create second credential in same folder' do
    params = {}
    params[:name] = 'Personal Mailbox'
    params[:folder_id] = folders(:folder1).id
    params[:type] = 'Encryptable::Credentials'
    credential = Encryptable::Credentials.new(params)
    expect(credential).to_not be_valid
    expect(credential.errors.first.attribute).to eq(:name)
  end

  it 'does create credential when no attribute set' do
    params = {}
    params[:name] = 'My biggest secret'
    params[:folder_id] = folders(:folder2).id
    params[:type] = 'Encryptable::Credentials'
    credential = Encryptable::Credentials.new(params)
    expect(credential).to be_valid
  end

  it 'creates second entryptable with credentials' do
    params = {}
    params[:name] = 'Shopping Account'
    params[:folder_id] = folders(:folder2).id
    params[:type] = 'Encryptable::Credentials'
    params[:cleartext_username] = 'username'
    credential = Encryptable::Credentials.new(params)
    expect(credential).to be_valid
  end

  it 'decrypts all attributes' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    encryptable.decrypt(team_password)

    expect(encryptable.cleartext_username).to eq('test')
    expect(encryptable.cleartext_password).to eq('password')
    expect(encryptable.cleartext_token).to eq('testtoken')
    expect(encryptable.cleartext_pin).to eq('testpin')
    expect(encryptable.cleartext_email).to eq('testemail')
    expect(encryptable.cleartext_custom_attr_label).to eq('Access Code')
    expect(encryptable.cleartext_custom_attr).to eq('abc42-code-42')
  end

  it 'updates all attributes' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    encryptable.cleartext_username = 'new'
    encryptable.cleartext_password = 'foo'
    encryptable.cleartext_token = 'boo'
    encryptable.cleartext_pin = 'loo'
    encryptable.cleartext_email = 'too'
    encryptable.cleartext_custom_attr_label = 'coo'
    encryptable.cleartext_custom_attr = 'yoo'

    encryptable.encrypt(team_password)
    encryptable.save!
    encryptable.reload
    encryptable.decrypt(team_password)

    expect(encryptable.cleartext_username).to eq('new')
    expect(encryptable.cleartext_password).to eq('foo')
    expect(encryptable.cleartext_token).to eq('boo')
    expect(encryptable.cleartext_pin).to eq('loo')
    expect(encryptable.cleartext_email).to eq('too')
    expect(encryptable.cleartext_custom_attr_label).to eq('coo')
    expect(encryptable.cleartext_custom_attr).to eq('yoo')
  end

  it 'does not create credential if name is empty' do
    params = {}
    params[:name] = ''
    params[:description] = 'foo foo'
    params[:type] = 'Encryptable::Credentials'

    credential = Encryptable::Credentials.new(params)

    credential.encrypted_data.[]=(:password, **{ data: 'foo', iv: nil })
    credential.encrypted_data.[]=(:username, **{ data: 'foo', iv: nil })
    credential.encrypted_data.[]=(:pin, **{ data: 'foo', iv: nil })
    credential.encrypted_data.[]=(:token, **{ data: 'foo', iv: nil })
    credential.encrypted_data.[]=(:email, **{ data: 'foo', iv: nil })
    credential.encrypted_data.[]=(:custom_attr, **{ label: 'foo', data: 'foo', iv: nil })

    expect(credential).to_not be_valid
    expect(credential.errors.full_messages.first).to match(/Name/)
  end
end
