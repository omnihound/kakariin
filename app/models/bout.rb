class Bout < ApplicationRecord
  belongs_to :match
  belongs_to :home_competitor, class_name: "Competitor"
  belongs_to :away_competitor, class_name: "Competitor", optional: true  # nil = forfeit/no-show
  belongs_to :winner, class_name: "Competitor", optional: true  # nil = pending or hikiwake (draw)

  has_many :ippons, as: :scoreable, dependent: :destroy

  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }

  # Kendo position names by team size; falls back to a plain ordinal for
  # uncommon lineup sizes.
  POSITION_NAMES = {
    3 => %w[Senpo Chuken Taisho],
    5 => %w[Senpo Jiho Chuken Fukusho Taisho]
  }.freeze

  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :position, uniqueness: { scope: :match_id }
  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :match_belongs_to_team_division
  validate :home_competitor_on_home_team
  validate :away_competitor_on_away_team, if: -> { away_competitor.present? }

  def position_label
    POSITION_NAMES[match.bouts.count]&.dig(position) || "Position #{position + 1}"
  end

  # Sync cached ippon totals from ippons. Winner is still set manually (via
  # winner_position), since kendo bouts can end 1-0 on time or hikiwake.
  def recalculate_score!
    update!(
      home_score: ippons.where(competitor: home_competitor).count,
      away_score: ippons.where(competitor: away_competitor).count
    )
  end

  private

  def match_belongs_to_team_division
    errors.add(:match, "must belong to a team division") if match && !match.division.team?
  end

  def home_competitor_on_home_team
    return unless match && home_competitor
    unless match.home.is_a?(TeamEntry) && match.home.competitors.include?(home_competitor)
      errors.add(:home_competitor, "must be a member of the home team")
    end
  end

  def away_competitor_on_away_team
    return unless match && away_competitor
    unless match.away.is_a?(TeamEntry) && match.away.competitors.include?(away_competitor)
      errors.add(:away_competitor, "must be a member of the away team")
    end
  end
end
