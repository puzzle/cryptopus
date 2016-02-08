# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class TeammembersController < ApplicationController
  before_filter :load_team
  helper_method :teammember_candidates

  # GET /teams/1/teammembers/new
  def new

  end

  # POST /teams/1/teammembers
  def create
    begin
      user = User.find_by_username params[:username]
      raise "User is not in the database" if user.nil?
      raise "User is already in that Team" \
        if @team.teammembers.where("user_id = ?", user.id).first
      @teammember = Teammember.new
      @teammember.team_id = @team.id
      @teammember.user_id = user.id
      @teammember.password = CryptUtils.encrypt_team_password( get_team_password(@team), user.public_key)
      @teammember.save

    rescue StandardError => e
      flash[:error] = e.message
    end

    respond_to do |format|
      format.html { redirect_to team_groups_url(@team) }
    end
  end

  # DELETE /teams/1/teammembers/1
  def destroy
    @teammember = @team.teammembers.find( params[:id] )

    if @team.teammembers.count == 1
      flash[:error] = t('flashes.teammembers.could_not_remove_last_teammember')
    elsif not can_destroy_teammember?(@teammember)
      flash[:error] = t('flashes.teammembers.could_not_remove_admin_from_private_team')
    else
      @teammember.destroy
    end

    respond_to do |format|
      format.html { redirect_to team_groups_url(@team) }
    end
  end

  private

    def can_destroy_teammember?(teammember)
      return false if teammember.user.root?
      @team.private? || !(teammember.user.admin?)
    end

    def load_team
      @team = Team.find( params[:team_id] )
    end

    def teammember_candidates
      users = @team.teammember_candidates.order(:username)
      users.pluck(:username)
    end
end
