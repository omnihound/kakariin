class Match < ApplicationRecord
  belongs_to :division
  belongs_to :pool, optional: true  # set for pool-stage matches; nil for playoff matches
  belongs_to :home, polymorphic: true
  belongs_to :away, polymorphic: true, optional: true
  belongs_to :winner, polymorphic: true, optional: true

  has_many :ippons, as: :scoreable, dependent: :destroy
  has_many :bouts, dependent: :destroy

  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed", bye: "bye" }

  validates :round, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :winner, absence: true, unless: :completed?

  # Sync cached ippon totals from ippons (individual divisions only).
  def recalculate_scores!
    return unless division.individual?
    update!(
      home_score: ippons.where(competitor: home).count,
      away_score: ippons.where(competitor: away).count
    )
  end

  # Keep the bout win tally current as bouts are added/scored (team divisions
  # only). Deliberately never promotes status to "completed" on its own:
  # bout data alone can't tell us whether the full lineup has been entered
  # yet, only that the bouts that exist so far are done. Call
  # finalize_team_result! to lock in the actual result.
  def recalculate_team_result!
    return unless division.team?
    return if completed?

    all_bouts = bouts.to_a
    return if all_bouts.empty?

    home_wins = all_bouts.count { |b| b.completed? && b.winner == b.home_competitor }
    away_wins = all_bouts.count { |b| b.completed? && b.winner == b.away_competitor }

    update!(home_score: home_wins, away_score: away_wins, status: "in_progress")
  end

  # Explicit organiser action: lock in the team match result from the bouts
  # entered so far. Winner: most bout wins; tied on wins -> most ippons
  # across all bouts; still tied -> hikiwake (draw), winner nil.
  def finalize_team_result!
    return unless division.team?

    all_bouts = bouts.to_a
    home_wins = all_bouts.count { |b| b.completed? && b.winner == b.home_competitor }
    away_wins = all_bouts.count { |b| b.completed? && b.winner == b.away_competitor }
    home_ippons = all_bouts.sum(&:home_score)
    away_ippons = all_bouts.sum(&:away_score)

    result_winner =
      if home_wins != away_wins
        home_wins > away_wins ? home : away
      elsif home_ippons != away_ippons
        home_ippons > away_ippons ? home : away
      end # else nil -> hikiwake

    update!(home_score: home_wins, away_score: away_wins, winner: result_winner,
            status: "completed", completed_at: Time.current)
  end
end
