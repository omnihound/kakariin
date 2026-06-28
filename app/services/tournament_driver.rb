require "tournament_system"

class TournamentDriver < TournamentSystem::Driver
  def initialize(division)
    @division = division
  end

  # For pools_then_elimination: only playoff matches (no pool_id).
  # For all other formats: every match in the division.
  def matches
    @matches ||= if @division.pools_then_elimination?
      @division.matches.where(pool_id: nil).to_a
    else
      @division.matches.to_a
    end
  end

  # For pools_then_elimination: qualifiers from each pool, interleaved by
  # finishing rank so same-pool opponents can't meet until later rounds.
  # For individual: confirmed registrations ordered by seed.
  # For team: confirmed team entries ordered by seed.
  def seeded_teams
    @seeded_teams ||= if @division.pools_then_elimination?
      playoff_qualifiers
    elsif @division.individual?
      @division.tournament_registrations
               .where(status: "confirmed")
               .order(Arel.sql("seed ASC NULLS LAST"))
               .map(&:competitor)
    else
      @division.team_entries
               .where(status: "confirmed")
               .order(Arel.sql("seed ASC NULLS LAST"))
               .to_a
    end
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
    @division.matches.create!(
      round: build_round,
      home: home_team,
      away: away_team,
      status: away_team.nil? ? "bye" : "pending"
    )
  end

  private

  # Interleave pool qualifiers by finishing rank across pools.
  # With 4 pools advancing 2 each the order is:
  #   Pool A 1st, Pool B 1st, Pool C 1st, Pool D 1st,
  #   Pool A 2nd, Pool B 2nd, Pool C 2nd, Pool D 2nd
  # This ensures same-pool opponents can't meet until the semi-finals or later.
  def playoff_qualifiers
    pools = @division.pools.order(:name).to_a
    max_advancing = pools.map(&:advancing_count).max

    (0...max_advancing).flat_map do |rank|
      pools.filter_map do |pool|
        PoolDriver.new(pool).ranked_teams[rank] if rank < pool.advancing_count
      end
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
