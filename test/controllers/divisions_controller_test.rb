require "test_helper"

class DivisionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "single_elimination division renders the bracket diagram" do
    get division_path(divisions(:individual))

    assert_response :success
    assert_select ".bracket-header", text: "Round 1"
    assert_select ".bracket-match"
    assert_select ".bracket-match.winner-locked", count: 0
  end

  test "seeded registrations show a seed badge on their bracket slot" do
    # individual_r1 fixture: hiroshi seed 1, sarah seed 2
    get division_path(divisions(:individual))

    assert_response :success
    assert_select ".bracket-seed", text: "1"
    assert_select ".bracket-seed", text: "2"
  end

  test "an in_progress match shows a live tag and running scores" do
    matches(:individual_r1).update!(status: "in_progress", home_score: 2, away_score: 1)

    get division_path(divisions(:individual))

    assert_response :success
    assert_select ".bracket-live-tag", text: "Live"
    assert_select ".bracket-score", text: "2"
    assert_select ".bracket-score", text: "1"
  end

  test "completing a match highlights its winner's path and shows the final score" do
    matches(:individual_r1).update!(winner: competitors(:hiroshi), status: "completed",
                                     home_score: 2, away_score: 0)

    get division_path(divisions(:individual))

    assert_response :success
    assert_select ".bracket-match.winner-locked"
    assert_select ".bracket-slot.won", text: /#{competitors(:hiroshi).full_name}/
    assert_select ".bracket-score", text: "2"
    assert_select ".bracket-live-tag", count: 0
  end

  test "a bye match shows an Adv tag instead of an opponent" do
    division = divisions(:individual)
    bye_match = division.matches.create!(round: 1, home: competitors(:tom), away: nil, status: "bye")

    get division_path(division)

    assert_response :success
    assert_select "#match_#{bye_match.id} .bracket-adv-tag", text: "Adv"
  end

  test "round_robin division keeps the plain match table, not the bracket" do
    division = Division.create!(tournament: tournaments(:states), name: "RR Division",
                                  competition_type: "individual", format: "round_robin")

    get division_path(division)

    assert_response :success
    assert_select ".bracket", count: 0
  end
end
