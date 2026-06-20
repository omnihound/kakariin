require "test_helper"

class CompetitorTest < ActiveSupport::TestCase
  test "full_name joins first and last name" do
    assert_equal "Hiroshi Tanaka", competitors(:hiroshi).full_name
  end

  test "grade_label combines rank and type" do
    assert_equal "3dan", competitors(:hiroshi).grade_label
  end

  test "grade_label is nil when ungraded" do
    competitor = Competitor.new(first_name: "A", last_name: "B", country: "AU")
    assert_nil competitor.grade_label
  end

  test "requires grade_type when grade_rank is present" do
    competitor = Competitor.new(first_name: "A", last_name: "B", country: "AU", grade_rank: 1)
    assert_not competitor.valid?
    assert_includes competitor.errors[:grade_type], "can't be blank"
  end

  test "requires grade_rank when grade_type is present" do
    competitor = Competitor.new(first_name: "A", last_name: "B", country: "AU", grade_type: "dan")
    assert_not competitor.valid?
    assert_includes competitor.errors[:grade_rank], "can't be blank"
  end

  test "valid when both grade fields are blank" do
    competitor = Competitor.new(first_name: "A", last_name: "B", country: "AU")
    assert competitor.valid?
  end

  test "requires first_name and last_name" do
    competitor = Competitor.new
    assert_not competitor.valid?
    assert_includes competitor.errors[:first_name], "can't be blank"
    assert_includes competitor.errors[:last_name], "can't be blank"
  end

  test "requires country explicitly even though the column defaults to AU" do
    competitor = Competitor.new(first_name: "A", last_name: "B", country: "")
    assert_not competitor.valid?
    assert_includes competitor.errors[:country], "can't be blank"
  end
end