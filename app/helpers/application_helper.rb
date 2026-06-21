module ApplicationHelper
  # home/away/winner on Match are polymorphic — Competitor for individual
  # divisions, TeamEntry for team divisions. This normalizes display.
  def participant_name(participant)
    return "BYE" if participant.nil?
    participant.is_a?(Competitor) ? participant.full_name : participant.name
  end

  # Seed for a bracket participant — looked up from the division's
  # tournament_registrations for individual competitors (no direct seed
  # column on Competitor), or read straight off TeamEntry#seed for teams.
  def participant_seed(participant, seed_lookup)
    return nil if participant.nil?
    participant.is_a?(Competitor) ? seed_lookup[participant.id] : participant.seed
  end

  TECHNIQUE_MARKS = { "men" => "M", "kote" => "K", "dou" => "D", "tsuki" => "T", "hansoku" => "H" }.freeze

  def technique_mark(technique)
    TECHNIQUE_MARKS.fetch(technique, technique.first.upcase)
  end

  def elapsed_time_label(seconds)
    return nil unless seconds
    format("%d:%02d", seconds / 60, seconds % 60)
  end

  # "M 0:47" if timed, otherwise just "M"
  def ippon_mark(ippon)
    time = elapsed_time_label(ippon.elapsed_seconds)
    time ? "#{technique_mark(ippon.technique)} #{time}" : technique_mark(ippon.technique)
  end

  # techniques a competitor scored within a scoreable, joined for a result summary line
  def winning_techniques_label(ippons, competitor)
    ippons.select { |i| i.competitor_id == competitor.id }.map { |i| i.technique.capitalize }.join(" + ")
  end

  # One tap-to-score button per technique, used identically for individual
  # matches and team bouts so ippon entry looks and behaves the same everywhere.
  def ippon_buttons(url, competitor_id)
    safe_join(
      Ippon.techniques.keys.map do |technique|
        button_to technique_mark(technique), url,
                  params: { ippon: { competitor_id: competitor_id, technique: technique } },
                  class: "ippon-btn", title: technique
      end
    )
  end
end