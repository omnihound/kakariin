require "test_helper"

class MatchTest < ActiveSupport::TestCase
  test "recalculate_scores! sums ippons for individual divisions" do
    match = matches(:individual_r1)
    Ippon.create!(scoreable: match, competitor: match.home, technique: "men")
    Ippon.create!(scoreable: match, competitor: match.home, technique: "kote")
    Ippon.create!(scoreable: match, competitor: match.away, technique: "dou")

    match.recalculate_scores!

    assert_equal 2, match.home_score
    assert_equal 1, match.away_score
  end

  test "recalculate_scores! does nothing for team divisions" do
    match = matches(:team_r1)
    match.update!(home_score: 5, away_score: 5)

    match.recalculate_scores!

    assert_equal 5, match.reload.home_score
  end

  test "recalculate_team_result! marks the match in_progress while bouts remain" do
    match = matches(:team_r1)
    build_bout(match, 0, competitors(:hiroshi), competitors(:sarah), winner: competitors(:hiroshi))

    match.recalculate_team_result!

    assert_equal "in_progress", match.status
    assert_equal 1, match.home_score
    assert_equal 0, match.away_score
    assert_nil match.winner
  end

  # Regression test: with only some of a planned lineup entered, the bouts
  # that exist so far can all be "completed" without the match itself being
  # over. recalculate_team_result! must never auto-promote to completed.
  test "recalculate_team_result! never marks the match completed on its own" do
    match = matches(:team_r1)
    build_bout(match, 0, competitors(:hiroshi), competitors(:sarah), winner: competitors(:hiroshi))

    match.recalculate_team_result!

    assert_equal "in_progress", match.status
  end

  test "finalize_team_result! sets the winner with the most bout wins" do
    match = matches(:team_r1)
    build_bout(match, 0, competitors(:hiroshi), competitors(:sarah), winner: competitors(:hiroshi))
    build_bout(match, 1, competitors(:tom), competitors(:yuki), winner: competitors(:tom))

    match.finalize_team_result!

    assert match.completed?
    assert_equal match.home, match.winner
    assert_equal 2, match.home_score
    assert_equal 0, match.away_score
  end

  test "finalize_team_result! breaks a tied win count on total ippons" do
    match = matches(:team_r1)
    build_bout(match, 0, competitors(:hiroshi), competitors(:sarah), winner: competitors(:hiroshi), home_score: 2, away_score: 1)
    build_bout(match, 1, competitors(:tom), competitors(:yuki), winner: competitors(:yuki), home_score: 0, away_score: 2)

    match.finalize_team_result!

    # 1-1 on wins; home ippons 2, away ippons 3 -> away wins on ippons
    assert match.completed?
    assert_equal match.away, match.winner
  end

  test "finalize_team_result! is a hikiwake draw when fully tied" do
    match = matches(:team_r1)
    build_bout(match, 0, competitors(:hiroshi), competitors(:sarah), winner: competitors(:hiroshi), home_score: 2, away_score: 0)
    build_bout(match, 1, competitors(:tom), competitors(:yuki), winner: competitors(:yuki), home_score: 0, away_score: 2)

    match.finalize_team_result!

    assert match.completed?
    assert_nil match.winner
  end

  test "winner must be absent unless the match is completed" do
    match = matches(:individual_r1)
    match.winner = match.home
    assert_not match.valid?
    assert_includes match.errors[:winner], "must be blank"
  end

  private

  def build_bout(match, position, home_competitor, away_competitor, winner:, home_score: 2, away_score: 0)
    match.bouts.create!(
      position: position,
      home_competitor: home_competitor,
      away_competitor: away_competitor,
      winner: winner,
      home_score: home_score,
      away_score: away_score,
      status: "completed"
    )
  end
end
