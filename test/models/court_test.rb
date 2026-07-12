require "test_helper"

class CourtTest < ActiveSupport::TestCase
  test "current_match returns the in_progress match assigned to this court" do
    court = courts(:court_1)
    match = matches(:individual_r1)
    match.update!(court: court, status: "in_progress")

    assert_equal match, court.current_match
  end

  test "current_match is nil when nothing is in progress" do
    court = courts(:court_1)
    matches(:individual_r1).update!(court: court)

    assert_nil court.current_match
  end

  test "next_match prefers the earliest scheduled pending match" do
    court = courts(:court_1)
    later = matches(:individual_r1)
    earlier = matches(:team_r1)
    later.update!(court: court, scheduled_at: 2.hours.from_now)
    earlier.update!(court: court, scheduled_at: 1.hour.from_now)

    assert_equal earlier, court.next_match
  end

  test "next_match falls back to round order for unscheduled matches" do
    court = courts(:court_1)
    round_two = matches(:individual_r1)
    round_two.update!(court: court, round: 2)
    round_one = matches(:team_r1)
    round_one.update!(court: court, round: 1)

    assert_equal round_one, court.next_match
  end

  test "next_match ranks scheduled matches ahead of unscheduled ones" do
    court = courts(:court_1)
    unscheduled = matches(:individual_r1)
    unscheduled.update!(court: court)
    scheduled = matches(:team_r1)
    scheduled.update!(court: court, scheduled_at: 1.hour.from_now)

    assert_equal scheduled, court.next_match
  end
end
