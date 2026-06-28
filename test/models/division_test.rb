require "test_helper"

class DivisionTest < ActiveSupport::TestCase
  test "name must be unique within a tournament" do
    duplicate = Division.new(
      tournament: tournaments(:states),
      name: divisions(:individual).name,
      competition_type: "individual",
      format: "single_elimination"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "same name is allowed in a different tournament" do
    other_tournament = Tournament.create!(name: "Other Cup", start_date: Date.new(2026, 1, 1))
    division = Division.new(
      tournament: other_tournament,
      name: divisions(:individual).name,
      competition_type: "individual",
      format: "single_elimination"
    )
    assert division.valid?
  end

  test "competition_type and format enums expose predicates" do
    assert divisions(:individual).individual?
    assert divisions(:team).team?
    assert divisions(:pools).pools_then_elimination?
  end
end
