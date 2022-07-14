# frozen_string_literal: true

require 'spec_helper'
describe EncryptableTransferPolicy do
  include PolicyHelper

  context 'File transfer' do


    it 'can transfer file' do
      assert_permit bob, transfer_file, :create?
    end

    it 'non teammember cant transfer credential' do
      refute_permit alice, transfer_file, :create?
    end

    it 'users can share file' do
      assert_permit bob, transfer_file, :update?
    end

  end

  private

  def transfer_file
    Encryptable::File.create!(
      name: 'Codes',
      description: 'Dont show anyone else',
      encryptable_credential: encryptables(:credentials2),
      content_type: 'text/plain',
      encrypted_data: '{"file":{"iv":null,"data":"FvJS9jooGEX1aXqB0iP7wB6h2YwO479OM+RpNmBlbORivbVPky0rR4u3lNLN+DGIL93gQAlVHDw1CZe9zDoTgSyxsQFflQwGk3DMDS9xhoQSJzTkBPBIb33j9H7WG37CQwdNNFnn/NExiBZb+9dbmHGqw8KWvRd3Xd/oSlTr6w/c0gz3UEYfhC5l6P3xnDc2"}}',
      sender_id: bob.id
    )
  end
end