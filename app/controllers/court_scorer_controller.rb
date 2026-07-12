class CourtScorerController < ApplicationController
  before_action :set_court

  def show
    @match = @court.current_match || @court.next_match
  end

  def start
    @court.next_match&.update!(status: "in_progress")
    redirect_to court_scorer_path(@court)
  end

  private

  def set_court
    @court = Court.find(params[:court_id])
  end
end
