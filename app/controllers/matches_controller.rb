class MatchesController < ApplicationController
  before_action :set_match

  def show; end
  def edit; end

  def update
    # For team divisions, winner/scores are derived from bouts via
    # Match#recalculate_team_result! — never set directly here.
    if @match.division.individual? && (position = params.dig(:match, :winner_position)).present?
      @match.winner = position == "home" ? @match.home : @match.away
      @match.status = "completed"
      @match.completed_at = Time.current
    end

    if @match.update(match_result_params)
      redirect_to redirect_target, notice: "Match updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def finalize
    @match.finalize_team_result!
    redirect_to redirect_target, notice: "Match finalized."
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def match_result_params
    permitted = params.require(:match).permit(:home_score, :away_score, :court_id, :scheduled_at, :status)
    @match.division.team? ? permitted.except(:home_score, :away_score) : permitted
  end

  # Scoring UI opened from the court scorer screen stays there between
  # matches instead of bouncing to the generic match page.
  def redirect_target
    params[:court_scorer].present? && @match.court ? court_scorer_path(@match.court) : @match
  end
end
