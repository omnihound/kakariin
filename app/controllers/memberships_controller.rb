class MembershipsController < ApplicationController
  before_action :set_team_entry

  def create
    membership = @team_entry.team_memberships.build(competitor_id: params[:competitor_id])
    if membership.save
      redirect_to @team_entry
    else
      redirect_to @team_entry, alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    @team_entry.team_memberships.find(params[:id]).destroy
    redirect_to @team_entry
  end

  private

  def set_team_entry
    @team_entry = TeamEntry.find(params[:team_entry_id])
  end
end
