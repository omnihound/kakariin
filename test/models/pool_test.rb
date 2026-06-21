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

  test "generate_for_division! splits confirmed registrations into pools by snake seed" do
    division = Division.create!(tournament: tournaments(:states), name: "Fresh Pools",
                                  competition_type: "individual", format: "pools_then_elimination")
    [ competitors(:hiroshi), competitors(:sarah), competitors(:james), competitors(:yuki) ].each_with_index do |c, i|
      division.tournament_registrations.create!(competitor: c, seed: i + 1, status: "confirmed")
    end

    pools = Pool.generate_for_division!(division, pool_count: 2, advancing_count: 1)

    assert_equal [ "Pool A", "Pool B" ], pools.map(&:name)
    assert_equal [ competitors(:hiroshi), competitors(:yuki) ], pools[0].pool_registrations.order(:seed).map(&:competitor)
    assert_equal [ competitors(:sarah), competitors(:james) ], pools[1].pool_registrations.order(:seed).map(&:competitor)
  end

  test "generate_for_division! refuses to run twice" do
    division = divisions(:pools)

    assert_raises(ArgumentError) { Pool.generate_for_division!(division, pool_count: 2, advancing_count: 1) }
  end

  test "generate_for_division! refuses when no confirmed registrations exist" do
    division = Division.create!(tournament: tournaments(:states), name: "Empty Pools",
                                  competition_type: "individual", format: "pools_then_elimination")

    assert_raises(ArgumentError) { Pool.generate_for_division!(division, pool_count: 2, advancing_count: 1) }
  end
end