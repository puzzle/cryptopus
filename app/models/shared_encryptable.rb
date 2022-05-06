# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  encryptable_id          :integer      not null
#  sender_id               :integer      not null
#  receiver_id             :integer      not null
#  read                    :boolean      default(FALSE)
#  share_password          :binary       not null

class SharedEncryptable < ApplicationRecord

end
