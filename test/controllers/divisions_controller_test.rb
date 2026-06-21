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

  test "completing a match highlights its winner's path in the bracket" do
    matches(:individual_r1).update!(winner: competitors(:hiroshi), status: "completed")

    get division_path(divisions(:individual))

    assert_response :success
    assert_select ".bracket-match.winner-locked"
    assert_select ".bracket-slot.won", text: /#{competitors(:hiroshi).full_name}/
  end

  test "round_robin division keeps the plain match table, not the bracket" do
    division = Division.create!(tournament: tournaments(:states), name: "RR Division",
                                  competition_type: "individual", format: "round_robin")

    get division_path(division)

    assert_response :success
    assert_select ".bracket", count: 0
  end
end
