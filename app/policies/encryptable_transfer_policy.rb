# frozen_string_literal: true

class EncryptableTransferPolicy < TeamDependantPolicy

   def create?
      current_user.present?
   end

end
