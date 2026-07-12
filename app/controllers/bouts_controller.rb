class BoutsController < ApplicationController
  before_action :set_match

  def create
    bout = @match.bouts.build(bout_lineup_params)
    if bout.save
      @match.recalculate_team_result!
      redirect_to redirect_target
    else
      redirect_to redirect_target, alert: bout.errors.full_messages.to_sentence
    end
  end

  def update
    bout = @match.bouts.find(params[:id])

    if (position = params.dig(:bout, :winner_position)).present?
      bout.winner = case position
      when "home" then bout.home_competitor
      when "away" then bout.away_competitor
      when "draw" then nil
      end
      bout.status = "completed"
    end

    if bout.update(bout_result_params)
      @match.recalculate_team_result!
      redirect_to redirect_target, notice: "Bout updated."
    else
      redirect_to redirect_target, alert: bout.errors.full_messages.to_sentence
    end
  end

  def destroy
    @match.bouts.find(params[:id]).destroy
    @match.recalculate_team_result!
    redirect_to redirect_target
  end

  private

  def set_match
    @match = Match.find(params[:match_id])
  end

  # Scoring UI opened from the court scorer screen stays there between
  # matches instead of bouncing to the generic match page.
  def redirect_target
    params[:court_scorer].present? && @match.court ? court_scorer_path(@match.court) : edit_match_path(@match)
  end

  def bout_lineup_params
    params.require(:bout).permit(:position, :home_competitor_id, :away_competitor_id)
  end

  def bout_result_params
    params.require(:bout).permit(:home_score, :away_score, :status)
  end
end
