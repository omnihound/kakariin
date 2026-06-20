require "test_helper"

class PoolTest < ActiveSupport::TestCase
  test "standings ranks competitors by win count" do
    pool = pools(:pool_a)
    # hiroshi beat james and tom (2 wins); tom beat james (1 win); james 0 wins
    assert_equal [ competitors(:hiroshi), competitors(:tom), competitors(:james) ], pool.standings
  end

  test "qualifiers returns the top advancing_count competitors" do
    pool = pools(:pool_a)
    assert_equal [ competitors(:hiroshi), competitors(:tom) ], pool.qualifiers
  end

  # Regression test: standings previously broke ties using array index from
  # whatever order pool_registrations were loaded in, not by seed. This
  # deliberately registers competitors in reverse-seed order to catch that.
  test "standings break ties by seed, not registration insertion order" do
    pool = Pool.create!(division: divisions(:pools), name: "Tiebreak Pool", advancing_count: 1)
    PoolRegistration.create!(pool: pool, competitor: competitors(:aiko), seed: 2)
    PoolRegistration.create!(pool: pool, competitor: competitors(:yuki), seed: 1)

    assert_equal [ competitors(:yuki), competitors(:aiko) ], pool.standings
  end

  test "all_matches_complete? is true once every pool match is completed" do
    assert pools(:pool_a).all_matches_complete?
  end

  test "all_matches_complete? is false for a pool with no matches yet" do
    assert_not pools(:pool_b).all_matches_complete?
  end
end