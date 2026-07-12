require "test_helper"

class CourtScorerControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "show displays the in_progress match on this court" do
    match = matches(:individual_r1)
    match.update!(court: courts(:court_1), status: "in_progress")

    get court_scorer_path(courts(:court_1))

    assert_response :success
    assert_select "h1", text: "#{courts(:court_1).name} — Scorer"
    assert_select ".scoreboard"
  end

  test "show falls back to the next pending match with a start button" do
    match = matches(:individual_r1)
    match.update!(court: courts(:court_1))

    get court_scorer_path(courts(:court_1))

    assert_response :success
    assert_select "form[action=?]", start_court_scorer_path(courts(:court_1))
  end

  test "show renders an empty state when nothing is queued" do
    get court_scorer_path(courts(:court_1))

    assert_response :success
    assert_select "p.muted", text: "No matches queued for this court."
  end

  test "start transitions the next pending match to in_progress" do
    match = matches(:individual_r1)
    match.update!(court: courts(:court_1))

    post start_court_scorer_path(courts(:court_1))

    assert_redirected_to court_scorer_path(courts(:court_1))
    assert_equal "in_progress", match.reload.status
  end

  test "after a match completes, the scorer view advances to the next queued match" do
    court = courts(:court_1)
    first = matches(:individual_r1)
    second = matches(:team_r1)
    first.update!(court: court, status: "in_progress")
    second.update!(court: court, round: 2)

    patch match_path(first, court_scorer: true), params: { match: { winner_position: "home" } }
    assert_redirected_to court_scorer_path(court)

    get court_scorer_path(court)
    assert_select "h2", text: /#{Regexp.escape(second.home.name)}/
  end
end
