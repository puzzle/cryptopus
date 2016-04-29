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
