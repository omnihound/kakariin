require "test_helper"

class BoutsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a bout to the lineup and updates the match tally" do
    match = matches(:team_r1)

    post match_bouts_path(match), params: {
      bout: { position: 0, home_competitor_id: competitors(:hiroshi).id, away_competitor_id: competitors(:sarah).id }
    }

    assert_redirected_to edit_match_path(match)
    assert_equal 1, match.bouts.count
  end

  test "create rejects a competitor not on the team roster" do
    match = matches(:team_r1)

    post match_bouts_path(match), params: {
      bout: { position: 0, home_competitor_id: competitors(:james).id, away_competitor_id: competitors(:sarah).id }
    }

    assert_redirected_to edit_match_path(match)
    assert_match(/must be a member of the home team/, flash[:alert])
    assert_equal 0, match.bouts.count
  end

  test "update scores a bout and refreshes the match tally without completing it" do
    match = matches(:team_r1)
    bout = match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))

    patch match_bout_path(match, bout), params: {
      bout: { home_score: 2, away_score: 0, winner_position: "home" }
    }

    assert_redirected_to edit_match_path(match)
    bout.reload
    assert_equal competitors(:hiroshi), bout.winner
    assert bout.completed?
    match.reload
    assert_equal "in_progress", match.status
    assert_equal 1, match.home_score
  end

  test "destroy removes a bout and recalculates the match tally" do
    match = matches(:team_r1)
    bout = match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah),
                                winner: competitors(:hiroshi), status: "completed")
    match.recalculate_team_result!
    assert_equal 1, match.reload.home_score

    delete match_bout_path(match, bout)

    assert_redirected_to edit_match_path(match)
    assert_equal 0, match.bouts.count
  end
end