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
    @pool.division.matches.create!(
      pool: @pool,
      round: build_round,
      home: home_team,
      away: away_team,
      status: away_team.nil? ? "bye" : "pending",
      court: away_team.nil? ? nil : court
    )
  end

  private

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
