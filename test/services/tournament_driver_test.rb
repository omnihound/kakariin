require "test_helper"

class TournamentDriverTest < ActiveSupport::TestCase
  test "matches returns every match for a non-pooled division" do
    driver = TournamentDriver.new(divisions(:individual))
    assert_equal [ matches(:individual_r1) ], driver.matches
  end

  test "matches excludes pool-stage matches for pools_then_elimination divisions" do
    driver = TournamentDriver.new(divisions(:pools))
    assert_equal [], driver.matches
  end

  test "matches includes only playoff matches once they exist" do
    division = divisions(:pools)
    playoff_match = division.matches.create!(round: 1, home: competitors(:hiroshi), away: competitors(:sarah), status: "pending")
    driver = TournamentDriver.new(division)
    assert_equal [ playoff_match ], driver.matches
  end

  test "seeded_teams returns confirmed individual registrations ordered by seed" do
    driver = TournamentDriver.new(divisions(:individual))
    assert_equal [ competitors(:hiroshi), competitors(:sarah), competitors(:james), competitors(:yuki) ], driver.seeded_teams
  end

  test "seeded_teams excludes unconfirmed registrations" do
    TournamentRegistration.create!(competitor: competitors(:aiko), division: divisions(:individual), status: "pending")
    driver = TournamentDriver.new(divisions(:individual))
    assert_not_includes driver.seeded_teams, competitors(:aiko)
  end

  test "seeded_teams returns confirmed team entries ordered by seed" do
    driver = TournamentDriver.new(divisions(:team))
    assert_equal [ team_entries(:melbourne), team_entries(:sydney) ], driver.seeded_teams
  end

  test "seeded_teams interleaves pool qualifiers by rank for pools_then_elimination" do
    driver = TournamentDriver.new(divisions(:pools))
    # pool_a qualifiers: hiroshi (1st, 2 wins), tom (2nd, 1 win)
    # pool_b qualifiers: sarah (1st, seed 1, 0 wins), yuki (2nd, seed 2, 0 wins)
    # interleaved by rank: [pool_a 1st, pool_b 1st, pool_a 2nd, pool_b 2nd]
    assert_equal [ competitors(:hiroshi), competitors(:sarah), competitors(:tom), competitors(:yuki) ], driver.seeded_teams
  end

  test "ranked_teams orders by win count, seed breaks ties" do
    matches(:individual_r1).update!(winner: competitors(:sarah), status: "completed")
    driver = TournamentDriver.new(divisions(:individual))
    assert_equal competitors(:sarah), driver.ranked_teams.first
  end

  test "get_team_score counts wins among the team's matches" do
    matches(:individual_r1).update!(winner: competitors(:hiroshi), status: "completed")
    driver = TournamentDriver.new(divisions(:individual))
    assert_equal 1, driver.get_team_score(competitors(:hiroshi))
    assert_equal 0, driver.get_team_score(competitors(:sarah))
  end

  test "get_match_teams and get_match_winner delegate to home/away/winner" do
    match = matches(:individual_r1)
    match.update!(winner: match.home, status: "completed")
    driver = TournamentDriver.new(divisions(:individual))
    assert_equal [ match.home, match.away ], driver.get_match_teams(match)
    assert_equal match.home, driver.get_match_winner(match)
  end

  test "build_match assigns round 1 when no matches exist yet" do
    division = Division.create!(tournament: tournaments(:states), name: "Empty Division",
                                 competition_type: "individual", format: "single_elimination")
    driver = TournamentDriver.new(division)
    match = driver.build_match(competitors(:hiroshi), competitors(:sarah))
    assert_equal 1, match.round
  end

  test "build_match keeps the same round while matches are still pending" do
    driver = TournamentDriver.new(divisions(:individual)) # individual_r1 fixture is pending
    match = driver.build_match(competitors(:james), competitors(:yuki))
    assert_equal 1, match.round
  end

  test "build_match assigns the next round once all existing matches are completed" do
    matches(:individual_r1).update!(winner: competitors(:hiroshi), status: "completed")
    driver = TournamentDriver.new(divisions(:individual))
    match = driver.build_match(competitors(:james), competitors(:yuki))
    assert_equal 2, match.round
  end

  test "build_match creates a bye when away_team is nil" do
    division = Division.create!(tournament: tournaments(:states), name: "Bye Division",
                                 competition_type: "individual", format: "single_elimination")
    driver = TournamentDriver.new(division)
    match = driver.build_match(competitors(:hiroshi), nil)
    assert_equal "bye", match.status
    assert_nil match.away
  end

  test "build_match assigns courts round-robin across the tournament's courts" do
    division = Division.create!(tournament: tournaments(:states), name: "Court Division",
                                 competition_type: "individual", format: "single_elimination")
    driver = TournamentDriver.new(division)
    match1 = driver.build_match(competitors(:hiroshi), competitors(:sarah))
    match2 = driver.build_match(competitors(:james), competitors(:yuki))
    match3 = driver.build_match(competitors(:tom), competitors(:aiko))

    assert_equal courts(:court_1), match1.court
    assert_equal courts(:court_2), match2.court
    assert_equal courts(:court_1), match3.court
  end

  test "build_match leaves court nil for byes" do
    division = Division.create!(tournament: tournaments(:states), name: "Bye Court Division",
                                 competition_type: "individual", format: "single_elimination")
    driver = TournamentDriver.new(division)
    match = driver.build_match(competitors(:hiroshi), nil)
    assert_nil match.court
  end
end
