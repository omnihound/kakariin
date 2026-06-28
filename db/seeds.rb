require "tournament_system"

# Idempotent — safe to re-run at any time.
# Creates a tournament with an 8-person individual bracket and a 4-team bracket,
# then runs bracket generation so you can inspect Match records in the console.

puts "== Default user"

User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = "password"
end

puts "  admin@example.com / password"

puts "== Competitors"

competitor_attrs = [
  { first_name: "Hiroshi", last_name: "Tanaka",    gender: "male",   grade_rank: 3, grade_type: "dan", country: "AU" },
  { first_name: "Sarah",   last_name: "Mitchell",  gender: "female", grade_rank: 2, grade_type: "dan", country: "AU" },
  { first_name: "James",   last_name: "Wong",      gender: "male",   grade_rank: 1, grade_type: "dan", country: "AU" },
  { first_name: "Yuki",    last_name: "Nakamura",  gender: "female", grade_rank: 1, grade_type: "kyu", country: "AU" },
  { first_name: "Tom",     last_name: "Robertson", gender: "male",   grade_rank: 2, grade_type: "dan", country: "AU" },
  { first_name: "Emma",    last_name: "Chen",      gender: "female", grade_rank: 1, grade_type: "dan", country: "AU" },
  { first_name: "David",   last_name: "Kim",       gender: "male",   grade_rank: 1, grade_type: "kyu", country: "AU" },
  { first_name: "Aiko",    last_name: "Yamamoto",  gender: "female", grade_rank: 2, grade_type: "dan", country: "AU" },
  { first_name: "Ben",     last_name: "Clarke",    gender: "male",   grade_rank: 1, grade_type: "dan", country: "AU" },
  { first_name: "Kenji",   last_name: "Suzuki",    gender: "male",   grade_rank: 2, grade_type: "dan", country: "AU" },
  { first_name: "Lucy",    last_name: "Anderson",  gender: "female", grade_rank: 1, grade_type: "kyu", country: "AU" },
  { first_name: "Mark",    last_name: "Patel",     gender: "male",   grade_rank: 1, grade_type: "dan", country: "AU" },
  { first_name: "Olivia",  last_name: "Walker",    gender: "female", grade_rank: 1, grade_type: "dan", country: "AU" },
  { first_name: "Ryo",     last_name: "Saito",     gender: "male",   grade_rank: 2, grade_type: "dan", country: "AU" },
  { first_name: "Grace",   last_name: "Liu",       gender: "female", grade_rank: 1, grade_type: "kyu", country: "AU" },
  { first_name: "Daniel",  last_name: "Nguyen",    gender: "male",   grade_rank: 1, grade_type: "kyu", country: "AU" }
]

competitors = competitor_attrs.map do |attrs|
  Competitor.find_or_create_by!(first_name: attrs[:first_name], last_name: attrs[:last_name]) do |c|
    c.assign_attributes(attrs)
  end
end

puts "  #{Competitor.count} competitors"

puts "== Tournament"

tournament = Tournament.find_or_create_by!(name: "2026 State Kendo Championships") do |t|
  t.location   = "Melbourne, VIC"
  t.start_date = Date.new(2026, 8, 15)
  t.end_date   = Date.new(2026, 8, 16)
  t.status     = "registration_open"
end

puts "  #{tournament.name}"

puts "== Divisions"

individual_div = Division.find_or_create_by!(tournament: tournament, name: "Open Individual") do |d|
  d.competition_type = "individual"
  d.format           = "single_elimination"
end

team_div = Division.find_or_create_by!(tournament: tournament, name: "Open Team") do |d|
  d.competition_type = "team"
  d.format           = "single_elimination"
end

championship_div = Division.find_or_create_by!(tournament: tournament, name: "Championship Individual") do |d|
  d.competition_type = "individual"
  d.format           = "single_elimination"
end

puts "  #{Division.count} divisions"

puts "== Individual registrations"

# 8 competitors, seeded by grade (highest dan first) then kyu
competitors.first(8).each_with_index do |competitor, i|
  TournamentRegistration.find_or_create_by!(competitor: competitor, division: individual_div) do |r|
    r.seed   = i + 1
    r.status = "confirmed"
  end
end

puts "  #{individual_div.tournament_registrations.confirmed.count} confirmed"

puts "== Championship registrations"

# All 16 competitors, seeded by grade (highest dan first) then kyu — a full
# 16-draw bracket (4 rounds), useful for exercising the bracket view at scale.
competitors.first(16).each_with_index do |competitor, i|
  TournamentRegistration.find_or_create_by!(competitor: competitor, division: championship_div) do |r|
    r.seed   = i + 1
    r.status = "confirmed"
  end
end

puts "  #{championship_div.tournament_registrations.confirmed.count} confirmed"

puts "== Team entries"

[
  { name: "Melbourne Kendo Club", members: competitors.values_at(0, 4, 8) },
  { name: "Sydney Kendo Renmei",  members: competitors.values_at(1, 5, 9) },
  { name: "Brisbane Kendo Kai",   members: competitors.values_at(2, 6, 10) },
  { name: "Adelaide Kendo Dojo",  members: competitors.values_at(3, 7, 11) }
].each_with_index do |data, i|
  team = TeamEntry.find_or_create_by!(division: team_div, name: data[:name]) do |t|
    t.seed   = i + 1
    t.status = "confirmed"
  end

  data[:members].each do |competitor|
    TeamMembership.find_or_create_by!(team_entry: team, competitor: competitor)
  end
end

puts "  #{TeamEntry.count} teams, #{TeamMembership.count} memberships"

puts "== Pools division"

pools_div = Division.find_or_create_by!(tournament: tournament, name: "Open Pools") do |d|
  d.competition_type = "individual"
  d.format           = "pools_then_elimination"
end

pool_a = Pool.find_or_create_by!(division: pools_div, name: "Pool A") { |p| p.advancing_count = 2 }
pool_b = Pool.find_or_create_by!(division: pools_div, name: "Pool B") { |p| p.advancing_count = 2 }

{ pool_a => competitors.values_at(0, 2, 4, 6), pool_b => competitors.values_at(1, 3, 5, 7) }.each do |pool, members|
  members.each_with_index do |competitor, i|
    PoolRegistration.find_or_create_by!(pool: pool, competitor: competitor) { |r| r.seed = i + 1 }
  end
end

puts "  #{Pool.count} pools, #{PoolRegistration.count} pool registrations"

puts "== Bracket generation"

if individual_div.matches.none?
  TournamentSystem::SingleElimination.generate(TournamentDriver.new(individual_div))
  puts "  Individual round 1:"
  individual_div.matches.order(:id).each do |m|
    away_label = m.away ? m.away.full_name : "BYE"
    puts "    #{m.home.full_name} vs #{away_label} [#{m.status}]"
  end
else
  puts "  Individual bracket already generated (#{individual_div.matches.count} matches), skipping"
end

if championship_div.matches.none?
  puts "  Playing out the 16-draw bracket (lower seed wins, with a few round-1 upsets so shiro/away wins show up in the bracket too)..."
  seed_for = ->(c) { championship_div.tournament_registrations.find_by(competitor: c).seed }
  total_rounds = TournamentSystem::SingleElimination.total_rounds(TournamentDriver.new(championship_div))
  # Home is always the better seed in round 1 (see TournamentSystem::Algorithm::SingleBracket.seed),
  # so picking the better seed every time would mean shiro (away) never wins. Flip these
  # round-1 match positions (0-indexed, in creation order) so the bracket view exercises both sides.
  round1_upset_positions = [ 1, 3, 5 ]

  total_rounds.times do |round_index|
    # TournamentDriver#matches caches @division.matches.to_a per instance,
    # but reusing championship_div across iterations means Rails' own
    # association cache on it goes stale once match records are updated
    # outside the cached array (the .where(...).update! below touches
    # separate object instances) — reset it so each round's driver sees the
    # real winners, not a stale "still pending" snapshot.
    championship_div.association(:matches).reset
    TournamentSystem::SingleElimination.generate(TournamentDriver.new(championship_div))
    current_round = championship_div.matches.maximum(:round)
    championship_div.matches.where(round: current_round, status: "pending").order(:id).each_with_index do |m, i|
      winner =
        if round_index.zero? && round1_upset_positions.include?(i)
          m.away
        else
          [ m.home, m.away ].compact.min_by(&seed_for)
        end
      m.update!(winner: winner, status: "completed")
    end
  end

  puts "  Resolved to the final:"
  championship_div.matches.order(:round, :id).each do |m|
    away_label = m.away ? m.away.full_name : "BYE"
    puts "    Round #{m.round}: #{m.home.full_name} vs #{away_label} -> #{m.winner.full_name}"
  end
  puts "  Champion: #{championship_div.matches.order(:round).last.winner.full_name}"
else
  puts "  Championship bracket already generated (#{championship_div.matches.count} matches), skipping"
end

if team_div.matches.none?
  TournamentSystem::SingleElimination.generate(TournamentDriver.new(team_div))
  puts "  Team round 1:"
  team_div.matches.order(:id).each do |m|
    away_label = m.away ? m.away.name : "BYE"
    puts "    #{m.home.name} vs #{away_label} [#{m.status}]"
  end

  puts "  Playing out bouts for non-bye matches (home wins 2 of 3 positions)..."
  team_div.matches.where.not(away_id: nil).each do |match|
    home_lineup = match.home.competitors.order(:id).to_a
    away_lineup = match.away.competitors.order(:id).to_a

    home_lineup.each_with_index do |home_competitor, position|
      away_competitor = away_lineup[position]
      winner = position < 2 ? home_competitor : away_competitor # home wins senpo+chuken, away wins taisho
      match.bouts.create!(
        position: position,
        home_competitor: home_competitor,
        away_competitor: away_competitor,
        winner: winner,
        home_score: winner == home_competitor ? 2 : 0,
        away_score: winner == away_competitor ? 2 : 0,
        status: "completed"
      )
    end
    match.finalize_team_result!
    puts "    #{match.home.name} #{match.home_score} - #{match.away_score} #{match.away.name} -> winner: #{match.winner.name}"
  end
else
  puts "  Team bracket already generated (#{team_div.matches.count} matches), skipping"
end

if pools_div.matches.none?
  puts "  Playing out pool stage (lower seed wins each match)..."
  [ pool_a, pool_b ].each do |pool|
    total_rounds = TournamentSystem::RoundRobin.total_rounds(PoolDriver.new(pool))
    total_rounds.times do
      TournamentSystem::RoundRobin.generate(PoolDriver.new(pool))
      pool.pool_matches.where(status: "pending").each do |m|
        seed_for = ->(c) { pool.pool_registrations.find_by(competitor: c).seed }
        winner = [ m.home, m.away ].compact.min_by(&seed_for)
        m.update!(winner: winner, status: "completed")
      end
    end
    puts "    #{pool.name} standings: #{pool.standings.map(&:full_name).join(', ')}"
  end

  TournamentSystem::SingleElimination.generate(TournamentDriver.new(pools_div))
  puts "  Playoff round 1 (qualifiers seeded across pools):"
  pools_div.matches.where(pool_id: nil).order(:id).each do |m|
    away_label = m.away ? m.away.full_name : "BYE"
    puts "    #{m.home.full_name} vs #{away_label} [#{m.status}]"
  end
else
  puts "  Pools division already generated (#{pools_div.matches.count} matches), skipping"
end

puts "== Done (#{Match.count} matches total)"
