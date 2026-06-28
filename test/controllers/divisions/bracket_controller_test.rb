require "test_helper"

module Divisions
  class BracketControllerTest < ActionDispatch::IntegrationTest
    setup { sign_in_as(users(:one)) }

    test "refuses to generate while matches are pending" do
      post division_bracket_path(divisions(:individual)) # individual_r1 fixture is pending

      assert_redirected_to divisions(:individual)
      assert_equal "Complete all pending matches before generating the next round.", flash[:alert]
      assert_equal 1, divisions(:individual).matches.count
    end

    test "generates the next single_elimination round once all matches are completed" do
      # individual_r1 fixture: 4 confirmed registrants but only 1 round-1 match
      # (james/yuki never paired) — use an isolated, fully-bracketed division
      # instead so completing "all matches" actually means a full round.
      division = Division.create!(tournament: tournaments(:states), name: "SE Division",
                                   competition_type: "individual", format: "single_elimination")
      [ :hiroshi, :sarah, :james, :yuki ].each_with_index do |key, i|
        TournamentRegistration.create!(competitor: competitors(key), division: division, seed: i + 1, status: "confirmed")
      end
      TournamentSystem::SingleElimination.generate(TournamentDriver.new(division))
      division.matches.each { |m| m.update!(winner: m.home, status: "completed") }

      post division_bracket_path(division)

      assert_redirected_to division
      assert division.matches.where(round: 2).exists?
    end

    test "generates round_robin matches for a round_robin division" do
      division = Division.create!(tournament: tournaments(:states), name: "RR Division",
                                   competition_type: "individual", format: "round_robin")
      [ :hiroshi, :sarah, :james, :yuki ].each_with_index do |key, i|
        TournamentRegistration.create!(competitor: competitors(key), division: division, seed: i + 1, status: "confirmed")
      end

      post division_bracket_path(division)

      assert_redirected_to division
      assert_equal 2, division.matches.where(round: 1).count
    end

    test "pools_then_elimination generates the next round for an incomplete pool only" do
      # pool_a fixtures already complete all 3 round-robin rounds; pool_b has none yet
      post division_bracket_path(divisions(:pools))

      assert_redirected_to divisions(:pools)
      assert_equal 3, pools(:pool_a).pool_matches.count, "pool_a was already complete and should not gain a 4th round"
      # 3 competitors get padded to 4 for round-robin pairing, so round 1 is 2 matches (one a bye)
      assert_equal 2, pools(:pool_b).pool_matches.count
    end

    test "pools_then_elimination generates the playoff bracket once every pool is complete" do
      # Complete pool_b's round-robin (3 competitors -> 3 rounds) directly
      [ [ :sarah, :yuki, :sarah ], [ :sarah, :aiko, :sarah ], [ :yuki, :aiko, :yuki ] ].each_with_index do |(home, away, winner), i|
        divisions(:pools).matches.create!(pool: pools(:pool_b), round: i + 1,
                                           home: competitors(home), away: competitors(away),
                                           winner: competitors(winner), status: "completed")
      end

      post division_bracket_path(divisions(:pools))

      assert_redirected_to divisions(:pools)
      playoff_matches = divisions(:pools).matches.where(pool_id: nil)
      assert_equal 2, playoff_matches.count
    end
  end
end
