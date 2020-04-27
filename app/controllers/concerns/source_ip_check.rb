# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module SourceIpCheck
  extend ActiveSupport::Concern

  included do
    before_action :check_source_ip
  end

  def check_root_source_ip
    redirect_to teams_path unless ip_checker.root_ip_authorized?
  end

  def check_source_ip
    return if ip_checker.previously_authorized?(session[:authorized_ip])

    if ip_checker.ip_authorized?
      session[:authorized_ip] = request.remote_ip
    else
      render layout: false, file: 'public/401.html', status: :unauthorized
    end
  end

  def ip_checker
    Authentication::SourceIpChecker.new(request.remote_ip)
  end
end
