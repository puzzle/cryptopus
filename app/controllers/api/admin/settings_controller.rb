# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::SettingsController < ApiController
  self.custom_model_class = Setting
  private

  def setting
    @setting ||= Setting.find(params[:id])
  end
end