require "test_helper"

class DivisionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "single_elimination division renders the bracket diagram" do
    get division_path(divisions(:individual))

    assert_response :success
    # individual_r1 fixture is the only match in the division (a 1-match,
    # 2-entrant bracket), so its round is also the final.
    assert_select ".bracket-header", text: "Final"
    assert_select ".bracket-match"
    assert_select ".bracket-match.winner-locked", count: 0
  end

  test "rounds not generated yet render as ghost cells with placeholders" do
    division = Division.create!(tournament: tournaments(:states), name: "Ghost Division",
                                  competition_type: "individual", format: "single_elimination")
    [ :hiroshi, :sarah, :james, :yuki ].each_with_index do |key, i|
      TournamentRegistration.create!(competitor: competitors(key), division: division, seed: i + 1, status: "confirmed")
    end
    TournamentSystem::SingleElimination.generate(TournamentDriver.new(division))

    get division_path(division)

    assert_response :success
    assert_select ".bracket-header", text: "Semifinal"
    assert_select ".bracket-header", text: "Final"
    assert_select ".bracket-match-ghost .bracket-placeholder", text: "Winner of Semifinal 1"
    assert_select ".bracket-match-ghost .bracket-placeholder", text: "Winner of Semifinal 2"
  end

  test "a ghost cell shows the real winner once its source match is decided" do
    division = Division.create!(tournament: tournaments(:states), name: "Ghost Decided Division",
                                  competition_type: "individual", format: "single_elimination")
    [ :hiroshi, :sarah, :james, :yuki ].each_with_index do |key, i|
      TournamentRegistration.create!(competitor: competitors(key), division: division, seed: i + 1, status: "confirmed")
    end
    TournamentSystem::SingleElimination.generate(TournamentDriver.new(division))
    first_match = division.matches.order(:id).first
    first_match.update!(winner: first_match.home, status: "completed")

    get division_path(division)

    assert_response :success
    assert_select ".bracket-match-ghost .bracket-slot-name", text: /#{first_match.home.full_name}/
    assert_select ".bracket-match-ghost .bracket-placeholder", text: "Winner of Semifinal 2"
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
