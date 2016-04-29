# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::LogsController < Admin::AdminController
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  # GET /logs
  def index
    @logs = Log.all
  end

  # GET /logs/1
  def show

  end

  # DELETE /logs/1
  def destroy
    @log.destroy
    redirect_to logs_url, notice: 'Log was successfully destroyed.'
  end
end
