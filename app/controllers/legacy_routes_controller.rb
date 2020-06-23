# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class LegacyRoutesController < ApplicationController

  layout false

  def redirect
    skip_authorization

    if url_handler.frontend_path?
      render 'frontend/index'
    else
      raise ActionController::RoutingError, 'Not Found' if request.path == url_handler.redirect_to

      redirect_to url_handler.redirect_to
    end
  end

  private

  def url_handler
    @url_handler ||= LegacyRoutes::UrlHandler.new(request.path)
  end
end
