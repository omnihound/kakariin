require "test_helper"

class IpponsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds an ippon to an individual match and updates its score" do
    match = matches(:individual_r1)

    post match_ippons_path(match), params: { ippon: { competitor_id: match.home.id, technique: "men" } }

    assert_redirected_to edit_match_path(match)
    assert_equal 1, match.ippons.count
    assert_equal 1, match.reload.home_score
  end

  test "create rejects a competitor who isn't in the match" do
    match = matches(:individual_r1)

    post match_ippons_path(match), params: { ippon: { competitor_id: competitors(:james).id, technique: "men" } }

    assert_redirected_to edit_match_path(match)
    assert_match(/must be a participant/, flash[:alert])
    assert_equal 0, match.ippons.count
  end

  test "destroy removes an ippon from a match and recalculates the score" do
    match = matches(:individual_r1)
    ippon = match.ippons.create!(competitor: match.home, technique: "men")
    match.recalculate_scores!
    assert_equal 1, match.reload.home_score

    delete match_ippon_path(match, ippon)

    assert_redirected_to edit_match_path(match)
    assert_equal 0, match.reload.home_score
  end

  test "create adds an ippon to a bout and updates the bout's score, not the match's" do
    match = matches(:team_r1)
    bout = match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))

    post match_bout_ippons_path(match, bout), params: { ippon: { competitor_id: competitors(:hiroshi).id, technique: "kote" } }

    assert_redirected_to edit_match_path(match)
    assert_equal 1, bout.reload.home_score
    assert_equal 0, match.reload.home_score # match score is bout win count, unaffected by ippons directly
  end

  test "destroy removes an ippon from a bout and recalculates the bout's score" do
    match = matches(:team_r1)
    bout = match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    ippon = bout.ippons.create!(competitor: competitors(:hiroshi), technique: "kote")
    bout.recalculate_score!
    assert_equal 1, bout.reload.home_score

    delete match_bout_ippon_path(match, bout, ippon)

    assert_equal 0, bout.reload.home_score
  end
end
