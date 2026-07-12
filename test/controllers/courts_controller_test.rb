require "test_helper"

class CourtsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index lists the tournament's courts" do
    get tournament_courts_path(tournaments(:states))

    assert_response :success
    assert_select "h3", text: courts(:court_1).name
    assert_select "h3", text: courts(:court_2).name
  end

  test "show displays the current match and upcoming queue" do
    matches(:individual_r1).update!(court: courts(:court_1), status: "in_progress")
    matches(:team_r1).update!(court: courts(:court_1), round: 2)

    get court_path(courts(:court_1))

    assert_response :success
    assert_select ".bracket-live-tag", text: "Live"
    assert_select "td", text: participant_name_for(matches(:team_r1).home)
  end

  test "index requires authentication" do
    sign_out
    get tournament_courts_path(tournaments(:states))
    assert_redirected_to new_session_path
  end

  test "live is publicly accessible without signing in and shows the court board" do
    matches(:individual_r1).update!(court: courts(:court_1), status: "in_progress")
    sign_out

    get live_court_path(courts(:court_1))

    assert_response :success
    assert_select "h1", text: "#{courts(:court_1).name} — Live"
    assert_select ".bracket-live-tag", text: "Live"
  end

  test "live shows a read-only scoreboard with no scoring controls for an elimination match" do
    match = matches(:individual_r1)
    match.update!(court: courts(:court_1), status: "in_progress")
    match.ippons.create!(competitor: match.home, technique: "men")

    get live_court_path(courts(:court_1))

    assert_response :success
    assert_select ".scoreboard"
    assert_select ".mark-remove", count: 0
    assert_select ".ippon-buttons", count: 0
  end

  test "live shows the pool matches table with the current match highlighted for a pool match" do
    pool_match = matches(:pool_a_r1_completed)
    pool_match.update!(status: "in_progress", winner: nil, completed_at: nil, court: courts(:court_1))

    get live_court_path(courts(:court_1))

    assert_response :success
    assert_select "h4", text: /#{Regexp.escape(pools(:pool_a).name)}/
    assert_select "tr.current-match-row"
    assert_select "table a", text: "Score", count: 0
  end

  private

  def participant_name_for(participant)
    participant.respond_to?(:full_name) ? participant.full_name : participant.name
  end
end
