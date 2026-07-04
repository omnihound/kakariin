class LineupsController < ApplicationController
  before_action :set_match

  def edit
    @positions = lineup_positions
    @bouts_by_position = @match.bouts.index_by(&:position)
  end

  def update
    ActiveRecord::Base.transaction do
      lineup_params.each do |position, attrs|
        position = position.to_i
        existing = @match.bouts.find_by(position: position)
        next if existing&.completed? || existing&.in_progress?

        if attrs[:home_competitor_id].blank?
          existing&.destroy!
          next
        end

        bout = existing || @match.bouts.build(position: position)
        bout.update!(
          home_competitor_id: attrs[:home_competitor_id],
          away_competitor_id: attrs[:away_competitor_id].presence
        )
      end
    end

    @match.recalculate_team_result!
    redirect_to edit_match_path(@match), notice: "Lineup saved."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_match_path(@match), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_match
    @match = Match.find(params[:match_id])
  end

  def lineup_positions
    size = [ @match.home.competitors.count, @match.away&.competitors&.count.to_i ].max
    (0...size)
  end

  # Keyed by position index ("0", "1", ...) rather than a plain array, so a
  # skipped position (left "— unset —" in the grid) never gets silently
  # renumbered into an adjacent slot.
  def lineup_params
    params.require(:lineup).permit(bouts: [ :home_competitor_id, :away_competitor_id ])[:bouts] || {}
  end
end
