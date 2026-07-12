require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "individual division: winner_position sets the winner directly" do
    match = matches(:individual_r1)

    patch match_path(match), params: { match: { winner_position: "home", home_score: 2, away_score: 0 } }

    assert_redirected_to match
    match.reload
    assert_equal match.home, match.winner
    assert match.completed?
    assert_equal 2, match.home_score
  end

  test "team division: home_score/away_score cannot be set directly via the match form" do
    match = matches(:team_r1)

    patch match_path(match), params: { match: { home_score: 99, away_score: 99, winner_position: "away" } }

    assert_redirected_to match
    match.reload
    assert_equal 0, match.home_score
    assert_equal 0, match.away_score
    assert_nil match.winner
  end

  test "team division: court_id and scheduled_at can still be set" do
    match = matches(:team_r1)

    patch match_path(match), params: { match: { court_id: courts(:court_1).id } }

    assert_equal courts(:court_1), match.reload.court
  end

  test "finalize locks in the team result from current bouts" do
    match = matches(:team_r1)
    match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah),
                         winner: competitors(:hiroshi), home_score: 2, away_score: 0, status: "completed")

    post finalize_match_path(match)

    assert_redirected_to match
    match.reload
    assert match.completed?
    assert_equal match.home, match.winner
  end

  test "court_scorer param redirects back to the court scorer view instead of the match" do
    match = matches(:individual_r1)
    match.update!(court: courts(:court_1), status: "in_progress")

    patch match_path(match, court_scorer: true), params: { match: { winner_position: "home" } }

    assert_redirected_to court_scorer_path(courts(:court_1))
  end

  test "finalize with court_scorer param redirects back to the court scorer view" do
    match = matches(:team_r1)
    match.update!(court: courts(:court_1))
    match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah),
                         winner: competitors(:hiroshi), home_score: 2, away_score: 0, status: "completed")

    post finalize_match_path(match, court_scorer: true)

    assert_redirected_to court_scorer_path(courts(:court_1))
  end

  test "show requires authentication" do
    sign_out
    get match_path(matches(:individual_r1))
    assert_redirected_to new_session_path
  end
end
