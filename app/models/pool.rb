class Pool < ApplicationRecord
  belongs_to :division

  has_many :pool_registrations, dependent: :destroy
  has_many :competitors, through: :pool_registrations

  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }

  validates :name, presence: true, uniqueness: { scope: :division_id }
  validates :advancing_count, numericality: { only_integer: true, greater_than: 0 }

  # Splits a division's confirmed registrations into pool_count pools using
  # snake seeding (seed 1, 2, 3... go one per pool, then reverse direction for
  # the next tier) so pool strength stays balanced. Refuses to run if the
  # division already has pools, since re-running would create duplicates
  # rather than reassigning existing ones.
  def self.generate_for_division!(division, pool_count:, advancing_count:)
    raise ArgumentError, "division already has pools" if division.pools.any?

    registrations = division.tournament_registrations.confirmed
                            .order(Arel.sql("seed ASC NULLS LAST")).to_a
    raise ArgumentError, "no confirmed registrations to assign" if registrations.empty?
    raise ArgumentError, "need at least 1 pool" if pool_count < 1

    transaction do
      pools = Array.new(pool_count) do |i|
        division.pools.create!(name: "Pool #{('A'.ord + i).chr}", advancing_count: advancing_count)
      end

      registrations.each_with_index do |registration, index|
        tier, offset = index.divmod(pool_count)
        pool_index = tier.even? ? offset : (pool_count - 1 - offset)
        pools[pool_index].pool_registrations.create!(competitor: registration.competitor, seed: index + 1)
      end

      pools
    end
  end

  # Competitors ranked by wins within this pool, ippon difference as
  # tiebreaker, then seed.
  def standings
    matches = matches_array
    pool_registrations.includes(:competitor)
                      .order(Arel.sql("seed ASC NULLS LAST"))
                      .sort_by.with_index { |pr, i| [ -win_count(pr.competitor, matches), -ippon_diff(pr.competitor, matches), i ] }
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

  # The match between two competitors within this pool, for cross-table cells.
  def match_between(a, b)
    matches_array.detect { |m| (m.home == a && m.away == b) || (m.home == b && m.away == a) }
  end

  def ippon_diff(competitor, matches = matches_array)
    ippons_for(competitor, matches) - ippons_against(competitor, matches)
  end

  private

  def matches_array
    @matches_array ||= pool_matches.to_a
  end

  def win_count(competitor, matches)
    matches.count { |m| m.winner == competitor }
  end

  def ippons_for(competitor, matches)
    matches.sum { |m| m.home == competitor ? m.home_score : (m.away == competitor ? m.away_score : 0) }
  end

  def ippons_against(competitor, matches)
    matches.sum { |m| m.home == competitor ? m.away_score : (m.away == competitor ? m.home_score : 0) }
  end
end
