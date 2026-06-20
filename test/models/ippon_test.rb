require "test_helper"

class IpponTest < ActiveSupport::TestCase
  test "valid when scoreable is a match and competitor is a participant" do
    match = matches(:individual_r1)
    ippon = Ippon.new(scoreable: match, competitor: match.home, technique: "men")
    assert ippon.valid?
  end

  test "invalid when competitor did not participate in the match" do
    match = matches(:individual_r1)
    ippon = Ippon.new(scoreable: match, competitor: competitors(:james), technique: "men")
    assert_not ippon.valid?
    assert_includes ippon.errors[:competitor], "must be a participant in this match"
  end

  test "valid when scoreable is a bout and competitor is a participant" do
    bout = matches(:team_r1).bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    ippon = Ippon.new(scoreable: bout, competitor: competitors(:hiroshi), technique: "kote")
    assert ippon.valid?
  end

  test "invalid when competitor did not fight in the bout" do
    bout = matches(:team_r1).bouts.create!(position: 0, home_competitor: competitors(:hiroshi), away_competitor: competitors(:sarah))
    ippon = Ippon.new(scoreable: bout, competitor: competitors(:tom), technique: "kote")
    assert_not ippon.valid?
    assert_includes ippon.errors[:competitor], "must be a participant in this match"
  end

  test "technique enum stores dou instead of the reserved word do" do
    match = matches(:individual_r1)
    ippon = Ippon.create!(scoreable: match, competitor: match.home, technique: "dou")
    assert_equal "dou", ippon.technique
    assert ippon.dou?
  end
end