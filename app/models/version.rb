# frozen_string_literal: true

class Version < PaperTrail::Version
  belongs_to :user, class_name: 'User', foreign_key: :whodunnit
  belongs_to :encryptable, class_name: 'Encryptable', foreign_key: :item_id
end
