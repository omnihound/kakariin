class IpponsController < ApplicationController
  before_action :set_scoreable

  def create
    ippon = @scoreable.ippons.build(ippon_params)
    if ippon.save
      recalculate!
      redirect_to redirect_target
    else
      redirect_to redirect_target, alert: ippon.errors.full_messages.to_sentence
    end
  end

  def destroy
    @scoreable.ippons.find(params[:id]).destroy
    recalculate!
    redirect_to redirect_target
  end

  private

  def set_scoreable
    @match = Match.find(params[:match_id])
    @scoreable = params[:bout_id].present? ? @match.bouts.find(params[:bout_id]) : @match
  end

  # Scoring UI opened from the court scorer screen stays there between
  # matches instead of bouncing to the generic match page.
  def redirect_target
    params[:court_scorer].present? && @match.court ? court_scorer_path(@match.court) : edit_match_path(@match)
  end

  def recalculate!
    @scoreable.is_a?(Match) ? @scoreable.recalculate_scores! : @scoreable.recalculate_score!
  end

  def ippon_params
    params.require(:ippon).permit(:competitor_id, :technique, :elapsed_seconds)
  end
end
