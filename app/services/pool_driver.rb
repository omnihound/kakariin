require "tournament_system"

# Drives round-robin match generation for a single pool within a
# pools_then_elimination division. Used for the pool stage only;
# the playoff stage is driven by TournamentDriver.
class PoolDriver < TournamentSystem::Driver
  def initialize(pool)
    @pool = pool
  end

  def matches
    @matches ||= @pool.pool_matches.to_a
  end

  def seeded_teams
    @seeded_teams ||= @pool.pool_registrations
                           .order(Arel.sql("seed ASC NULLS LAST"))
                           .map(&:competitor)
  end

  def ranked_teams
    seeded_teams.sort_by.with_index { |team, i| [ -get_team_score(team), i ] }
  end

  def get_match_winner(match)
    match.winner
  end

  def get_match_teams(match)
    [ match.home, match.away ]
  end

  def get_team_score(team)
    get_team_matches(team).count { |m| get_match_winner(m) == team }
  end

  def get_team_matches(team)
    matches.select { |m| m.home == team || m.away == team }
  end

  def build_match(home_team, away_team)
    if away_team.nil?
      return @pool.division.matches.create!(
        pool: @pool, round: build_round, home: home_team, away: nil, status: "bye"
      )
    end

    aka, shiro = assign_sides(home_team, away_team)
    @pool.division.matches.create!(
      pool: @pool, round: build_round, home: aka, away: shiro, status: "pending", court: court
    )
  end

  private

  # The round-robin algorithm's own home/away choice alternates every round to
  # balance totals, which flips a competitor's aka/shiro side on every match
  # they play. Pool competitors sit at the same table for their whole
  # round-robin, so we override that: keep each competitor on the side they
  # played last (a bye in between doesn't change anything for them).
  #
  # When both competitors last played the same side, one has to flip — prefer
  # flipping whoever's last match was longer ago (they've already had a bye to
  # "reset" on), and keep the side of whoever played the very last round, since
  # flipping them breaks an unbroken run with no rest in between.
  def assign_sides(team_a, team_b)
    a_match = last_match(team_a)
    b_match = last_match(team_b)
    a_side = a_match && (a_match.home == team_a ? :aka : :shiro)
    b_side = b_match && (b_match.home == team_b ? :aka : :shiro)

    if a_side && b_side && a_side == b_side
      if a_match.round >= b_match.round
        a_side == :aka ? [ team_a, team_b ] : [ team_b, team_a ]
      else
        b_side == :aka ? [ team_b, team_a ] : [ team_a, team_b ]
      end
    elsif a_side == :shiro || b_side == :aka
      [ team_b, team_a ]
    else
      [ team_a, team_b ]
    end
  end

  def last_match(team)
    matches.select { |m| !m.bye? && (m.home == team || m.away == team) }.max_by(&:round)
  end

  # A pool's whole round-robin plays on one court so competitors in that pool
  # aren't shuffled between courts mid-pool. Different pools spread across the
  # tournament's courts by their position among the division's pools.
  def court
    @court ||= begin
      courts = @pool.division.tournament.courts.order(:name).to_a
      return nil if courts.empty?
      pools = @pool.division.pools.order(:name).to_a
      courts[pools.index(@pool) % courts.size]
    end
  end

  def build_round
    @build_round ||= begin
      if matches.empty?
        1
      elsif matches.all? { |m| %w[completed bye].include?(m.status) }
        matches.map(&:round).max + 1
      else
        matches.map(&:round).max
      end
    end
  end
end
