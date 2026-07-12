require "test_helper"

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  test "live is publicly accessible without signing in" do
    get live_tournament_path(tournaments(:states))

    assert_response :success
    assert_select "h1", text: /Live/
  end

  test "live shows the current match on each court" do
    matches(:individual_r1).update!(court: courts(:court_1), status: "in_progress")

    get live_tournament_path(tournaments(:states))

    assert_response :success
    assert_select ".bracket-live-tag", text: "Live"
  end

  test "index still requires authentication" do
    get tournaments_path
    assert_redirected_to new_session_path
  end
end
