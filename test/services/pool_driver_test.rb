require "test_helper"

class PoolDriverTest < ActiveSupport::TestCase
  test "matches returns only this pool's matches" do
    driver = PoolDriver.new(pools(:pool_a))
    assert_equal pools(:pool_a).pool_matches.to_a.sort_by(&:id), driver.matches.sort_by(&:id)
  end

  test "seeded_teams returns pool registrations ordered by seed" do
    driver = PoolDriver.new(pools(:pool_a))
    assert_equal [ competitors(:hiroshi), competitors(:james), competitors(:tom) ], driver.seeded_teams
  end

  test "ranked_teams orders by win count within the pool" do
    driver = PoolDriver.new(pools(:pool_a))
    # hiroshi beat james and tom (2 wins); tom beat james (1 win); james 0 wins
    assert_equal [ competitors(:hiroshi), competitors(:tom), competitors(:james) ], driver.ranked_teams
  end

  test "get_team_score counts wins within the pool only" do
    driver = PoolDriver.new(pools(:pool_a))
    assert_equal 2, driver.get_team_score(competitors(:hiroshi))
    assert_equal 0, driver.get_team_score(competitors(:james))
  end

  test "build_match assigns round 1 for a pool with no matches yet" do
    driver = PoolDriver.new(pools(:pool_b))
    match = driver.build_match(competitors(:sarah), competitors(:yuki))
    assert_equal 1, match.round
    assert_equal pools(:pool_b), match.pool
    assert_equal divisions(:pools), match.division
  end

  test "build_match assigns the next round once the pool's existing matches are completed" do
    driver = PoolDriver.new(pools(:pool_a)) # fixtures: rounds 1-3 all completed
    match = driver.build_match(competitors(:hiroshi), competitors(:james))
    assert_equal 4, match.round
  end

  test "build_match assigns every match in a pool to the same court" do
    driver = PoolDriver.new(pools(:pool_b))
    match1 = driver.build_match(competitors(:sarah), competitors(:yuki))
    match2 = driver.build_match(competitors(:sarah), competitors(:aiko))
    assert_equal match1.court, match2.court
  end

  test "build_match assigns different pools to different courts" do
    pool_a_match = PoolDriver.new(pools(:pool_a)).build_match(competitors(:hiroshi), competitors(:james))
    pool_b_match = PoolDriver.new(pools(:pool_b)).build_match(competitors(:sarah), competitors(:yuki))

    assert_equal courts(:court_1), pool_a_match.court
    assert_equal courts(:court_2), pool_b_match.court
  end
end
