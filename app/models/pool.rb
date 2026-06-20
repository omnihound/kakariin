class Pool < ApplicationRecord
  belongs_to :division

  has_many :pool_registrations, dependent: :destroy
  has_many :competitors, through: :pool_registrations

  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }

  validates :name, presence: true, uniqueness: { scope: :division_id }
  validates :advancing_count, numericality: { only_integer: true, greater_than: 0 }

  # Competitors ranked by wins within this pool, seed as tiebreaker.
  def standings
    pool_registrations.includes(:competitor)
                      .order(Arel.sql("seed ASC NULLS LAST"))
                      .sort_by.with_index { |pr, i| [-win_count(pr.competitor), i] }
                      .map(&:competitor)
  end

  # Competitors who qualify for the playoff stage.
  def qualifiers
    standings.first(advancing_count)
  end

  def all_matches_complete?
    pool_matches.any? && pool_matches.all? { |m| m.completed? || m.bye? }
  end

  def pool_matches
    division.matches.where(pool: self)
  end

  private

  def win_count(competitor)
    pool_matches.count { |m| m.winner == competitor }
  end
end