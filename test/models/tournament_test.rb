require "test_helper"

class TournamentTest < ActiveSupport::TestCase
  test "valid with required fields" do
    tournament = Tournament.new(name: "Test Cup", start_date: Date.new(2026, 1, 1))
    assert tournament.valid?
  end

  test "requires name and start_date" do
    tournament = Tournament.new
    assert_not tournament.valid?
    assert_includes tournament.errors[:name], "can't be blank"
    assert_includes tournament.errors[:start_date], "can't be blank"
  end

  test "end_date cannot be before start_date" do
    tournament = Tournament.new(
      name: "Test Cup",
      start_date: Date.new(2026, 8, 16),
      end_date: Date.new(2026, 8, 15)
    )
    assert_not tournament.valid?
    assert_includes tournament.errors[:end_date], "must be greater than or equal to 2026-08-16"
  end

  test "status defaults to draft" do
    assert_equal "draft", Tournament.new.status
  end
end