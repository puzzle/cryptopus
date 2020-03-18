# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class LegacyRoutesController < ApplicationController

  def redirect
    skip_authorization
    raise ActionController::RoutingError, 'Not Found' if request.path == redirect_url

    redirect_to redirect_url
  end

  private

  def redirect_url
    LegacyRoutes::RedirectUrl.new(request.path).redirect_to
  end
end
