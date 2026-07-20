require "test_helper"

class BoutTest < ActiveSupport::TestCase
  test "valid with a home competitor on the home team and away competitor on the away team" do
    bout = Bout.new(match: matches(:team_r1), position: 0,
                     home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    assert bout.valid?
  end

  test "invalid when home_competitor is not on the home team's roster" do
    bout = Bout.new(match: matches(:team_r1), position: 0,
                     home_competitor: competitors(:james), away_competitor: competitors(:sarah))
    assert_not bout.valid?
    assert_includes bout.errors[:home_competitor], "must be a member of the home team"
  end

  test "invalid when away_competitor is not on the away team's roster" do
    bout = Bout.new(match: matches(:team_r1), position: 0,
                     home_competitor: competitors(:hiroshi), away_competitor: competitors(:james))
    assert_not bout.valid?
    assert_includes bout.errors[:away_competitor], "must be a member of the away team"
  end

  test "away_competitor may be nil to represent a forfeit" do
    bout = Bout.new(match: matches(:team_r1), position: 0,
                     home_competitor: competitors(:hiroshi), away_competitor: nil)
    assert bout.valid?
  end

  test "invalid when the match belongs to an individual division" do
    bout = Bout.new(match: matches(:individual_r1), position: 0,
                     home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    assert_not bout.valid?
    assert_includes bout.errors[:match], "must belong to a team division"
  end

  test "position must be unique within a match" do
    matches(:team_r1).bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    duplicate = Bout.new(match: matches(:team_r1), position: 0,
                          home_competitor: competitors(:tom), away_competitor: competitors(:yuki))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:position], "has already been taken"
  end

  test "position_label resolves kendo position names for a 3-bout lineup" do
    match = matches(:team_r1)
    match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    match.bouts.create!(position: 1, home_competitor: competitors(:tom), away_competitor: competitors(:yuki))
    senpo = match.bouts.find_by(position: 0)

    # only 2 bouts exist so far -> not in the 3-name lookup table -> falls back
    assert_equal "Position 1", senpo.position_label
  end

  test "position_label falls back to an ordinal for uncommon lineup sizes" do
    match = matches(:team_r1)
    bout = match.bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    assert_equal "Position 1", bout.position_label
  end

  test "recalculate_score! sums ippons per competitor" do
    bout = matches(:team_r1).bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    Ippon.create!(scoreable: bout, competitor: competitors(:hiroshi), technique: "men")
    Ippon.create!(scoreable: bout, competitor: competitors(:hiroshi), technique: "kote")
    Ippon.create!(scoreable: bout, competitor: competitors(:sarah), technique: "dou")

    bout.recalculate_score!

    assert_equal 2, bout.home_score
    assert_equal 1, bout.away_score
  end

  test "recalculate_score! awards an ippon for every 2 hansoku conceded" do
    bout = matches(:team_r1).bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    Ippon.create!(scoreable: bout, competitor: competitors(:hiroshi), technique: "hansoku")
    Ippon.create!(scoreable: bout, competitor: competitors(:hiroshi), technique: "hansoku")

    bout.recalculate_score!

    assert_equal 0, bout.home_score
    assert_equal 1, bout.away_score
  end
end
