class Match < ApplicationRecord
  belongs_to :division
  belongs_to :pool, optional: true  # set for pool-stage matches; nil for playoff matches
  belongs_to :court, optional: true
  belongs_to :home, polymorphic: true
  belongs_to :away, polymorphic: true, optional: true
  belongs_to :winner, polymorphic: true, optional: true

  has_many :ippons, as: :scoreable, dependent: :destroy
  has_many :bouts, dependent: :destroy

  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed", bye: "bye" }

  validates :round, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :winner, absence: true, unless: :completed?
  validate :court_not_already_in_progress, if: -> { court_id.present? && in_progress? }

  after_commit :broadcast_live_updates, on: [ :create, :update ]

  # Sync cached ippon totals from ippons (individual divisions only). Hansoku
  # fouls aren't points on their own: every 2 hansoku conceded by a
  # competitor award one ippon to their opponent.
  def recalculate_scores!
    return unless division.individual?
    home_ippons = ippons.where(competitor: home)
    away_ippons = ippons.where(competitor: away)
    update!(
      home_score: home_ippons.where.not(technique: "hansoku").count + away_ippons.hansoku.count / 2,
      away_score: away_ippons.where.not(technique: "hansoku").count + home_ippons.hansoku.count / 2
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

  # Pushes the latest score/status out to whoever's watching this match live:
  # the pool's matches table, the division bracket, and the court board all
  # key off it, so a spectator or scorer never has to refresh to see a change
  # made elsewhere. Public since Bout re-triggers it for ippon-by-ippon
  # progress within a team match.
  def broadcast_live_updates
    if pool_id.present?
      broadcast_replace_to pool,
                            target: ActionView::RecordIdentifier.dom_id(pool, :matches),
                            partial: "divisions/pools/matches_table",
                            locals: { pool: pool }
    elsif !division.round_robin?
      broadcast_replace_to division,
                            target: ActionView::RecordIdentifier.dom_id(division, :bracket),
                            partial: "divisions/bracket",
                            locals: { division: division, matches: division.matches.where(pool_id: nil).order(:round, :id) }
    end

    return unless court_id.present?
    broadcast_replace_to court,
                          target: ActionView::RecordIdentifier.dom_id(court, :board),
                          partial: "courts/board",
                          locals: { court: court }
  end

  private

  # Keeps "the active match for this court" unambiguous for the court status
  # board and scorer view.
  def court_not_already_in_progress
    if court.matches.in_progress.where.not(id: id).exists?
      errors.add(:court, "already has a match in progress")
    end
  end
end
