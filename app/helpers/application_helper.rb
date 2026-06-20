module ApplicationHelper
  # home/away/winner on Match are polymorphic — Competitor for individual
  # divisions, TeamEntry for team divisions. This normalizes display.
  def participant_name(participant)
    return "BYE" if participant.nil?
    participant.is_a?(Competitor) ? participant.full_name : participant.name
  end
end