class IpponsController < ApplicationController
  before_action :set_scoreable

  def create
    ippon = @scoreable.ippons.build(ippon_params)
    if ippon.save
      recalculate!
      redirect_to edit_match_path(@match)
    else
      redirect_to edit_match_path(@match), alert: ippon.errors.full_messages.to_sentence
    end
  end

  def destroy
    @scoreable.ippons.find(params[:id]).destroy
    recalculate!
    redirect_to edit_match_path(@match)
  end

  private

  def set_scoreable
    @match = Match.find(params[:match_id])
    @scoreable = params[:bout_id].present? ? @match.bouts.find(params[:bout_id]) : @match
  end

  def recalculate!
    @scoreable.is_a?(Match) ? @scoreable.recalculate_scores! : @scoreable.recalculate_score!
  end

  def ippon_params
    params.require(:ippon).permit(:competitor_id, :technique, :elapsed_seconds)
  end
end